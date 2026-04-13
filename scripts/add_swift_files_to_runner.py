#!/usr/bin/env python3
"""
Add Runner/LLM/*.swift and Runner/MLXBridge.swift to the Runner target's
PBXSourcesBuildPhase and PBXGroup in the Xcode project.
"""

import os
import uuid
import glob

PBXPROJ = os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner.xcodeproj', 'project.pbxproj')
LLM_DIR = os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner', 'LLM')

RUNNER_GROUP = '97C146F01CF9000F007C117D'  # Runner file group
SOURCES_PHASE = '97C146EA1CF9000F007C117D'  # Runner's sources build phase

def gen_uuid():
    return uuid.uuid4().hex[:24].upper()

def main():
    with open(PBXPROJ, 'r') as f:
        content = f.read()

    if 'MLXBridge.swift' in content and 'MLXLocalLLMService.swift' in content:
        print('Swift files already in project. Skipping.')
        return

    # Collect all Swift files
    swift_files = []

    # MLXBridge.swift
    swift_files.append(('MLXBridge.swift', 'Runner/MLXBridge.swift'))

    # LLM directory
    for path in sorted(glob.glob(os.path.join(LLM_DIR, '**', '*.swift'), recursive=True)):
        rel = os.path.relpath(path, os.path.join(os.path.dirname(__file__), '..', 'ios', 'Runner'))
        name = os.path.basename(path)
        swift_files.append((name, f'Runner/{rel}'))

    # Generate file references and build file entries
    file_ref_entries = []
    build_file_entries = []
    source_build_refs = []
    group_children = []

    for name, path in swift_files:
        fr_uuid = gen_uuid()
        bf_uuid = gen_uuid()

        file_ref_entries.append(
            f'\t\t{fr_uuid} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = "<group>"; }};'
        )
        build_file_entries.append(
            f'\t\t{bf_uuid} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {fr_uuid} /* {name} */; }};'
        )
        source_build_refs.append(f'\t\t\t\t{bf_uuid} /* {name} in Sources */,')
        group_children.append(f'\t\t\t\t{fr_uuid} /* {name} */,')

    # Add file references
    content = content.replace(
        '/* End PBXFileReference section */',
        '\n'.join(file_ref_entries) + '\n/* End PBXFileReference section */'
    )

    # Add build files
    content = content.replace(
        '/* End PBXBuildFile section */',
        '\n'.join(build_file_entries) + '\n/* End PBXBuildFile section */'
    )

    # Add to sources build phase
    sources_pattern = f'{SOURCES_PHASE} /* Sources */ = {{\n\t\t\tisa = PBXSourcesBuildPhase;\n\t\t\tbuildActionMask = 2147483647;\n\t\t\tfiles = ('
    sources_replacement = sources_pattern + '\n' + '\n'.join(source_build_refs)
    content = content.replace(sources_pattern, sources_replacement)

    # Add to Runner group children
    runner_group_pattern = f'{RUNNER_GROUP} /* Runner */ = {{\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = ('
    runner_group_replacement = runner_group_pattern + '\n' + '\n'.join(group_children)
    content = content.replace(runner_group_pattern, runner_group_replacement)

    with open(PBXPROJ, 'w') as f:
        f.write(content)

    print(f'✅ Added {len(swift_files)} Swift files to Runner target')
    for name, _ in swift_files:
        print(f'  + {name}')

if __name__ == '__main__':
    main()
