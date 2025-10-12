#!/usr/bin/env python3
import re
import uuid

# Leer el archivo project.pbxproj
project_file = 'ios/Runner.xcodeproj/project.pbxproj'
with open(project_file, 'r') as f:
    content = f.read()

# Generar UUIDs únicos para las referencias
file_ref_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]
build_file_uuid = str(uuid.uuid4()).replace('-', '').upper()[:24]

# 1. Agregar PBXFileReference
file_ref_pattern = r'(\/\* Begin PBXFileReference section \*\/.*?)(\/\* End PBXFileReference section \*\/)'
file_ref_addition = f'\t\t{file_ref_uuid} /* GoogleService-Info.plist */ = {{isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; }};\n'

def add_file_reference(match):
    return match.group(1) + file_ref_addition + '\t\t' + match.group(2)

content = re.sub(file_ref_pattern, add_file_reference, content, flags=re.DOTALL)

# 2. Agregar PBXBuildFile
build_file_pattern = r'(\/\* Begin PBXBuildFile section \*\/.*?)(\/\* End PBXBuildFile section \*\/)'
build_file_addition = f'\t\t{build_file_uuid} /* GoogleService-Info.plist in Resources */ = {{isa = PBXBuildFile; fileRef = {file_ref_uuid} /* GoogleService-Info.plist */; }};\n'

def add_build_file(match):
    return match.group(1) + build_file_addition + '\t\t' + match.group(2)

content = re.sub(build_file_pattern, add_build_file, content, flags=re.DOTALL)

# 3. Agregar a PBXGroup (carpeta Runner)
group_pattern = r'(97C146F01CF9000F007C117D \/\* Runner \*\/ = \{.*?children = \(.*?)(74858FAD1ED2DC5600515810 \/\* Runner-Bridging-Header\.h \*\/,)'
group_addition = f'\t\t\t\t{file_ref_uuid} /* GoogleService-Info.plist */,\n\t\t\t\t'

def add_to_group(match):
    return match.group(1) + group_addition + match.group(2)

content = re.sub(group_pattern, add_to_group, content, flags=re.DOTALL)

# 4. Agregar a PBXResourcesBuildPhase
resources_pattern = r'(97C146EC1CF9000F007C117D \/\* Resources \*\/ = \{.*?files = \(.*?)(97C146FC1CF9000F007C117D \/\* Main\.storyboard in Resources \*\/,)'
resources_addition = f'\t\t\t\t{build_file_uuid} /* GoogleService-Info.plist in Resources */,\n\t\t\t\t'

def add_to_resources(match):
    return match.group(1) + resources_addition + match.group(2)

content = re.sub(resources_pattern, add_to_resources, content, flags=re.DOTALL)

# Escribir el archivo modificado
with open(project_file, 'w') as f:
    f.write(content)

print("✅ GoogleService-Info.plist agregado correctamente al proyecto Xcode!")
print(f"FileRef UUID: {file_ref_uuid}")
print(f"BuildFile UUID: {build_file_uuid}")