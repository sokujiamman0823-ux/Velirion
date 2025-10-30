const fs = require('fs');
const path = require('path');

console.log('🧹 Creating EXACT match for deployed bytecode...\n');

const inputFile = path.join(__dirname, 'flattened_contracts', 'VelirionToken_flattened_EXACT.sol');
const outputFile = path.join(__dirname, 'flattened_contracts', 'VelirionToken_VERIFIED.sol');

let content = fs.readFileSync(inputFile, 'utf8');

// Remove all "Original license" comments
content = content.replace(/\/\/ Original license: SPDX_License_Identifier: MIT\n/g, '');

// Remove duplicate pragma statements (keep only first)
let pragmaFound = false;
const lines = content.split('\n');
const cleanedLines = lines.filter(line => {
    if (line.match(/^pragma solidity/)) {
        if (!pragmaFound) {
            pragmaFound = true;
            return true; // Keep first pragma
        }
        return false; // Remove subsequent pragmas
    }
    return true; // Keep all other lines
});

content = cleanedLines.join('\n');

// Remove excessive blank lines (more than 2 consecutive)
content = content.replace(/\n{3,}/g, '\n\n');

// Write cleaned content
fs.writeFileSync(outputFile, content, 'utf8');

console.log('✅ Created: VelirionToken_VERIFIED.sol');
console.log('\n📋 This file should match the deployed bytecode EXACTLY');
console.log('\n⚠️  Use this file for Etherscan verification with:');
console.log('   - Compiler: v0.8.20+commit.a1b79de6');
console.log('   - Optimization: YES (200 runs)');
console.log('   - License: MIT');
console.log('   - Constructor Args: (leave empty)\n');
