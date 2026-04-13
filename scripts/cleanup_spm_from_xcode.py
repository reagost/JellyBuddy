#!/usr/bin/env python3
"""Remove SPM entries added by add_spm_to_xcode.py from the pbxproj."""

import re
import os

PBXPROJ = os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner.xcodeproj', 'project.pbxproj')

with open(PBXPROJ, 'r') as f:
    content = f.read()

# Remove XCLocalSwiftPackageReference section
content = re.sub(
    r'\n/\* Begin XCLocalSwiftPackageReference section \*/.*?/\* End XCLocalSwiftPackageReference section \*/\n',
    '\n', content, flags=re.DOTALL
)

# Remove XCSwiftPackageProductDependency section
content = re.sub(
    r'\n/\* Begin XCSwiftPackageProductDependency section \*/.*?/\* End XCSwiftPackageProductDependency section \*/\n',
    '\n', content, flags=re.DOTALL
)

# Remove localPackages from project object
content = re.sub(
    r'\s*localPackages = \([^)]*\);', '', content
)

# Remove packageProductDependencies from Runner target
content = re.sub(
    r'\s*packageProductDependencies = \([^)]*\);', '', content
)

# Remove build files referencing MLX products
content = re.sub(r'\t\t[A-F0-9]+ /\* MLX\w+ in Frameworks \*/ = \{[^}]+\};\n', '', content)

# Remove framework phase entries for MLX
content = re.sub(r'\t\t\t\t[A-F0-9]+ /\* MLX\w+ in Frameworks \*/,\n', '', content)

# Remove build files referencing our Swift files (MLXBridge, LLM files)
content = re.sub(r'\t\t[A-F0-9]+ /\* \w+\.swift in Sources \*/ = \{isa = PBXBuildFile; fileRef = [A-F0-9]+ /\* \w+\.swift \*/; \};\n', '', content)

# Remove file references for Runner/LLM and MLXBridge
content = re.sub(r'\t\t[A-F0-9]+ /\* \w+\.swift \*/ = \{isa = PBXFileReference;[^}]+Runner/(?:LLM|MLXBridge)[^}]+\};\n', '', content)

# Remove source build phase entries for our files
content = re.sub(r'\t\t\t\t[A-F0-9]+ /\* \w+\.swift in Sources \*/,\n', '', content)

# Remove group children entries
content = re.sub(r'\t\t\t\t[A-F0-9]+ /\* (?:MLXBridge|BundledModel|GPULifecycle|MLXTokenizersLoader|MemoryStats|RuntimeBudgets|Gemma4\w+|ModelDownloader|ModelInstall\w+|ModelPaths|LLMEngine|MLXLocalLLMService\+?(?:KVReuse)?|MLXLocalLLMService)\.swift \*/,\n', '', content)

with open(PBXPROJ, 'w') as f:
    f.write(content)

print('✅ SPM entries cleaned from pbxproj')
