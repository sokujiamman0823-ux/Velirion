use anchor_lang::prelude::*;
use anchor_spl::token::{self, Burn, Mint, MintTo, Token, TokenAccount, Transfer};

declare_id!("CXf7sapvuMh9oK4D9HcSJDHqTjoo5yK1LsppTXeXMHzn");

/// Velirion SPL Token Program
/// Implements a deflationary token with 0.5% automatic burn on transfers
#[program]
pub mod velirion_spl {
    use super::*;

    /// Initialize the Velirion token mint
    /// Creates the mint with specified decimals and authority
    pub fn initialize(ctx: Context<Initialize>, decimals: u8) -> Result<()> {
        msg!("Initializing Velirion SPL Token");
        msg!("Decimals: {}", decimals);
        msg!("Mint Authority: {}", ctx.accounts.mint_authority.key());
        
        // Mint is created via CPI in the Initialize context
        Ok(())
    }

    /// Mint new tokens to a specified account
    /// Only the mint authority can call this function
    pub fn mint_tokens(
        ctx: Context<MintTokens>,
        amount: u64,
    ) -> Result<()> {
        require!(amount > 0, ErrorCode::InvalidAmount);
        
        msg!("Minting {} tokens to {}", amount, ctx.accounts.to.key());
        
        let cpi_accounts = MintTo {
            mint: ctx.accounts.mint.to_account_info(),
            to: ctx.accounts.to.to_account_info(),
            authority: ctx.accounts.authority.to_account_info(),
        };
        
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        
        token::mint_to(cpi_ctx, amount)?;
        
        msg!("Successfully minted {} tokens", amount);
        Ok(())
    }

    /// Transfer tokens with automatic 0.5% burn
    /// Burns 0.5% of the transfer amount, sending the rest to recipient
    pub fn transfer_with_burn(
        ctx: Context<TransferWithBurn>,
        amount: u64,
    ) -> Result<()> {
        require!(amount > 0, ErrorCode::InvalidAmount);
        require!(amount >= 200, ErrorCode::AmountTooSmall); // Minimum to allow 0.5% burn
        
        // Calculate burn amount (0.5% = 5/1000)
        let burn_amount = amount
            .checked_mul(5)
            .ok_or(ErrorCode::MathOverflow)?
            .checked_div(1000)
            .ok_or(ErrorCode::MathOverflow)?;
        
        // Calculate transfer amount (99.5%)
        let transfer_amount = amount
            .checked_sub(burn_amount)
            .ok_or(ErrorCode::MathOverflow)?;
        
        msg!("Transfer amount: {}", amount);
        msg!("Burn amount (0.5%): {}", burn_amount);
        msg!("Net transfer: {}", transfer_amount);
        
        // Transfer tokens to recipient
        let transfer_accounts = Transfer {
            from: ctx.accounts.from.to_account_info(),
            to: ctx.accounts.to.to_account_info(),
            authority: ctx.accounts.authority.to_account_info(),
        };
        
        let transfer_ctx = CpiContext::new(
            ctx.accounts.token_program.to_account_info(),
            transfer_accounts,
        );
        
        token::transfer(transfer_ctx, transfer_amount)?;
        
        // Burn tokens
        if burn_amount > 0 {
            let burn_accounts = Burn {
                mint: ctx.accounts.mint.to_account_info(),
                from: ctx.accounts.from.to_account_info(),
                authority: ctx.accounts.authority.to_account_info(),
            };
            
            let burn_ctx = CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                burn_accounts,
            );
            
            token::burn(burn_ctx, burn_amount)?;
            msg!("Burned {} tokens", burn_amount);
        }
        
        emit!(TransferEvent {
            from: ctx.accounts.from.key(),
            to: ctx.accounts.to.key(),
            amount,
            burn_amount,
            transfer_amount,
        });
        
        Ok(())
    }

    /// Burn tokens manually
    /// Allows token holders to burn their own tokens
    pub fn burn_tokens(
        ctx: Context<BurnTokens>,
        amount: u64,
    ) -> Result<()> {
        require!(amount > 0, ErrorCode::InvalidAmount);
        
        msg!("Burning {} tokens from {}", amount, ctx.accounts.from.key());
        
        let cpi_accounts = Burn {
            mint: ctx.accounts.mint.to_account_info(),
            from: ctx.accounts.from.to_account_info(),
            authority: ctx.accounts.authority.to_account_info(),
        };
        
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        
        token::burn(cpi_ctx, amount)?;
        
        emit!(BurnEvent {
            from: ctx.accounts.from.key(),
            amount,
        });
        
        msg!("Successfully burned {} tokens", amount);
        Ok(())
    }
}

// ============================================================================
// Contexts
// ============================================================================

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(
        init,
        payer = payer,
        mint::decimals = 9,
        mint::authority = mint_authority,
    )]
    pub mint: Account<'info, Mint>,
    
    /// CHECK: This is the mint authority
    pub mint_authority: AccountInfo<'info>,
    
    #[account(mut)]
    pub payer: Signer<'info>,
    
    pub system_program: Program<'info, System>,
    pub token_program: Program<'info, Token>,
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
pub struct MintTokens<'info> {
    #[account(mut)]
    pub mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub to: Account<'info, TokenAccount>,
    
    pub authority: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct TransferWithBurn<'info> {
    #[account(mut)]
    pub mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub from: Account<'info, TokenAccount>,
    
    #[account(mut)]
    pub to: Account<'info, TokenAccount>,
    
    pub authority: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct BurnTokens<'info> {
    #[account(mut)]
    pub mint: Account<'info, Mint>,
    
    #[account(mut)]
    pub from: Account<'info, TokenAccount>,
    
    pub authority: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

// ============================================================================
// Events
// ============================================================================

#[event]
pub struct TransferEvent {
    pub from: Pubkey,
    pub to: Pubkey,
    pub amount: u64,
    pub burn_amount: u64,
    pub transfer_amount: u64,
}

#[event]
pub struct BurnEvent {
    pub from: Pubkey,
    pub amount: u64,
}

// ============================================================================
// Errors
// ============================================================================

#[error_code]
pub enum ErrorCode {
    #[msg("Invalid amount: must be greater than 0")]
    InvalidAmount,
    
    #[msg("Amount too small: minimum 200 tokens required for 0.5% burn")]
    AmountTooSmall,
    
    #[msg("Math overflow occurred")]
    MathOverflow,
}
