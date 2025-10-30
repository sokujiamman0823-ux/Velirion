const fs = require('fs');
const path = require('path');

console.log('🧹 Cleaning all flattened Solidity files...\n');

const flattenedDir = path.join(__dirname, 'flattened_contracts');
const files = fs.readdirSync(flattenedDir).filter(f => f.endsWith('_flattened.sol'));

files.forEach(filename => {
    const filePath = path.join(flattenedDir, filename);
    console.log(`📄 Processing: ${filename}`);
    
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Count before
    const originalLicenseCount = (content.match(/\/\/ Original license: SPDX_License_Identifier: MIT/g) || []).length;
    const pragmaCount = (content.match(/pragma solidity/g) || []).length;
    
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
    fs.writeFileSync(filePath, content, 'utf8');
    
    console.log(`  ✅ Removed ${originalLicenseCount} duplicate licenses`);
    console.log(`  ✅ Kept 1 pragma, removed ${pragmaCount - 1} duplicates`);
    console.log(`  ✅ Cleaned successfully\n`);
});

console.log('✨ All files cleaned and ready for Etherscan verification!');
console.log('\n⚠️  IMPORTANT: When verifying on Etherscan:');
console.log('   - Compiler: v0.8.20+commit.a1b79de6');
console.log('   - Optimization: YES (200 runs) ← CRITICAL!');
console.log('   - License: MIT\n');
