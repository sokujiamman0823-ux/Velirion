#!/bin/bash
# Fix the deploy.ts file by removing the problematic lines

sed -i '66,71d' scripts/deploy.ts
sed -i '65a\      })' scripts/deploy.ts

echo "✅ Fixed deploy.ts - removed systemProgram, tokenProgram, and rent from accounts"
