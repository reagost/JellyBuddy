#!/usr/bin/env python3
"""
Add InferenceKit local SPM package to Runner.xcodeproj.

This modifies the pbxproj file to add:
1. XCLocalSwiftPackageReference for InferenceKit
2. XCSwiftPackageProductDependency for MLXLLM, MLXVLM, MLXLMCommon
3. Link these to the Runner target's frameworks phase
"""

import os
import re
import uuid

PBXPROJ = os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner.xcodeproj', 'project.pbxproj')

RUNNER_TARGET = '97C146ED1CF9000F007C117D'
PROJECT_OBJECT = '97C146E61CF9000F007C117D'
FRAMEWORKS_PHASE = '97C146EB1CF9000F007C117D'  # Runner's frameworks build phase

def gen_uuid():
    """Generate a 24-char uppercase hex UUID for Xcode."""
    return uuid.uuid4().hex[:24].upper()

def main():
    with open(PBXPROJ, 'r') as f:
        content = f.read()

    # Check if already added
    if 'InferenceKit' in content:
        print('InferenceKit already in project. Skipping.')
        return

    # Generate UUIDs
    pkg_ref_uuid = gen_uuid()
    dep_mlxllm_uuid = gen_uuid()
    dep_mlxvlm_uuid = gen_uuid()
    dep_mlxlmcommon_uuid = gen_uuid()
    bf_mlxllm_uuid = gen_uuid()
    bf_mlxvlm_uuid = gen_uuid()
    bf_mlxlmcommon_uuid = gen_uuid()

    # 1. Add XCLocalSwiftPackageReference section
    spm_section = f"""
/* Begin XCLocalSwiftPackageReference section */
\t\t{pkg_ref_uuid} /* XCLocalSwiftPackageReference "InferenceKit" */ = {{
\t\t\tisa = XCLocalSwiftPackageReference;
\t\t\trelativePath = Packages/InferenceKit;
\t\t}};
/* End XCLocalSwiftPackageReference section */
"""

    # 2. Add XCSwiftPackageProductDependency section
    dep_section = f"""
/* Begin XCSwiftPackageProductDependency section */
\t\t{dep_mlxllm_uuid} /* MLXLLM */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {pkg_ref_uuid} /* XCLocalSwiftPackageReference "InferenceKit" */;
\t\t\tproductName = MLXLLM;
\t\t}};
\t\t{dep_mlxvlm_uuid} /* MLXVLM */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {pkg_ref_uuid} /* XCLocalSwiftPackageReference "InferenceKit" */;
\t\t\tproductName = MLXVLM;
\t\t}};
\t\t{dep_mlxlmcommon_uuid} /* MLXLMCommon */ = {{
\t\t\tisa = XCSwiftPackageProductDependency;
\t\t\tpackage = {pkg_ref_uuid} /* XCLocalSwiftPackageReference "InferenceKit" */;
\t\t\tproductName = MLXLMCommon;
\t\t}};
/* End XCSwiftPackageProductDependency section */
"""

    # Insert these sections before the final closing
    content = content.replace(
        '/* End XCConfigurationList section */',
        '/* End XCConfigurationList section */\n' + spm_section + dep_section
    )

    # 3. Add localPackages to project object
    content = content.replace(
        f'{PROJECT_OBJECT} /* Project object */ = {{',
        f'{PROJECT_OBJECT} /* Project object */ = {{\n\t\t\tlocalPackages = (\n\t\t\t\t{pkg_ref_uuid} /* XCLocalSwiftPackageReference "InferenceKit" */,\n\t\t\t);'
    )

    # 4. Add packageProductDependencies to Runner target
    # Find the Runner target block and add packageProductDependencies
    runner_pattern = f'{RUNNER_TARGET} /* Runner */ = {{\n\t\t\tisa = PBXNativeTarget;'
    runner_replacement = f'{RUNNER_TARGET} /* Runner */ = {{\n\t\t\tisa = PBXNativeTarget;\n\t\t\tpackageProductDependencies = (\n\t\t\t\t{dep_mlxllm_uuid} /* MLXLLM */,\n\t\t\t\t{dep_mlxvlm_uuid} /* MLXVLM */,\n\t\t\t\t{dep_mlxlmcommon_uuid} /* MLXLMCommon */,\n\t\t\t);'
    content = content.replace(runner_pattern, runner_replacement)

    # 5. Add build file entries for frameworks phase
    bf_entries = f"""\t\t{bf_mlxllm_uuid} /* MLXLLM in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_mlxllm_uuid} /* MLXLLM */; }};
\t\t{bf_mlxvlm_uuid} /* MLXVLM in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_mlxvlm_uuid} /* MLXVLM */; }};
\t\t{bf_mlxlmcommon_uuid} /* MLXLMCommon in Frameworks */ = {{isa = PBXBuildFile; productRef = {dep_mlxlmcommon_uuid} /* MLXLMCommon */; }};
"""

    # Add to PBXBuildFile section
    content = content.replace(
        '/* End PBXBuildFile section */',
        bf_entries + '/* End PBXBuildFile section */'
    )

    # Add to frameworks build phase files list
    fw_files_addition = f"""\t\t\t\t{bf_mlxllm_uuid} /* MLXLLM in Frameworks */,
\t\t\t\t{bf_mlxvlm_uuid} /* MLXVLM in Frameworks */,
\t\t\t\t{bf_mlxlmcommon_uuid} /* MLXLMCommon in Frameworks */,"""

    # Find the frameworks build phase and add entries
    fw_pattern = f'{FRAMEWORKS_PHASE} /* Frameworks */ = {{\n\t\t\tisa = PBXFrameworksBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = ('
    fw_replacement = fw_pattern + '\n' + fw_files_addition
    content = content.replace(fw_pattern, fw_replacement)

    with open(PBXPROJ, 'w') as f:
        f.write(content)

    print('✅ InferenceKit SPM package added to Runner.xcodeproj')
    print()
    print('Next steps:')
    print('  1. Open ios/Runner.xcworkspace in Xcode')
    print('  2. Xcode will resolve mlx-swift SPM dependency (~2 min)')
    print('  3. Add Runner/LLM/*.swift files to the Runner target (drag in Xcode)')
    print('  4. Build & run on a real device (iPhone with Apple Silicon)')

if __name__ == '__main__':
    main()
