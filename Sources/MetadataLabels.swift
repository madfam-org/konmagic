import Foundation

// Mirrors Atlas's filename/collection labels. These are observations, not
// semantic proof, preservation guarantees or instructions to delete anything.
enum MetadataLabels {
    static let families:[String:Set<String>]=[
        "Documents":["pdf","doc","docx","odt","rtf","txt","md","rst","tex","adoc","asciidoc","bib","csl","ps"],
        "Spreadsheets":["xls","xlsx","ods","csv","tsv"],"Presentations":["ppt","pptx","odp"],
        "Images":["jpg","jpeg","png","heic","webp","gif","tif","tiff","bmp","ico","svg","psd","xcf","eps"],
        "Video":["mov","mp4","mkv","avi","webm"],"Audio":["mp3","wav","aiff","aif","m4a","flac","ogg"],
        "Design & fabrication":["stl","step","stp","obj","mtl","ply","scad","3mf","blend","f3d","glb","gltf","dph","inf","img","revo","3dm","dwg"],
        "Books":["epub","azw3","mobi"],"Archives":["zip","tar","gz","7z","rar","dmg","iso"],
        "Configuration":["ini","cfg","conf","strings","plist","properties","lock","nuspec","service","desktop","tsbuildinfo","example","typed","license"],
        "Logs":["log","out","err"],"Databases":["sqlite","sqlite3","db"],
        "Program code":["a","o","so","dylib","dll","exe","class","wasm"],"Fonts":["ttf","otf","woff","woff2"],
        "Code":["py","js","ts","tsx","jsx","go","rs","css","sql","json","yaml","yml","toml","html","xml","c","h","cpp","hpp","sh","zsh","bash","mjs","cjs","astro","svelte","vue","mdx","ipynb","dart","inc","hbs","ejs","j2","sum","mod","patch","diff","snap","scadtest","golden","xsd","cc","mako","lua","r","rb","gradle","kt","kts","swift","fish","ps1","cs","sln","csproj","tf","tfvars","graphql","proto","prisma","avsc","proto3","bat","tcl","ino","f","f90"]
    ]
    static let generated:Set<String>=[".atlas-recovery",".git",".obsidian","node_modules",".next",".venv","venv","__pycache__",".cache","vendor","dist","build","target","coverage","lcov-report",".nyc_output",".pytest_cache",".mypy_cache",".ruff_cache",".turbo",".tox","site-packages"]
    static let secrets:Set<String>=["secrets","private","credentials",".ssh",".gnupg",".aws",".azure",".kube",".password-store","gcloud","gh",".zsh_sessions",".bash_sessions",".ipython"]
    static let appState:Set<String>=[".codex",".claude",".gemini",".cursor",".windsurf",".antigravity",".vscode",".vscode-insiders",".vscode-shared",".config",".ollama",".Trash",".dropbox",".dropbox-dist",".docker",".wine",".codeium",".serena",".expo",".terraform.d",".logseq",".openjfx",".oracle_jre_usage",".matplotlib",".keras",".conda","FontBase"]
    static let roles:[String:String]=["credentials":"Protected credentials","audit":"Audit records","generated":"Rebuildable candidate","app_state":"Application-owned data","managed":"Managed collection","system":"Operating system","repository":"Repository","source_project":"Source project","vault":"Obsidian vault","book_library":"Book library","scan_project":"3D scan collection"]
    static func tags(path:String,kind:String,inherited:String)->[String:String] {
        let url=URL(fileURLWithPath:path),parts=path.split(separator:"/").map(String.init),name=url.lastPathComponent,ext=url.pathExtension.lowercased()
        var family=kind=="directory" ? "Folder" : kind=="link" ? "Link" : "Other",boundary=inherited.isEmpty ? "user_data" : inherited
        if kind=="file" {for (key,extensions) in families where extensions.contains(ext) {family=key;break}}
        let secretParts=(parts.first=="private" ? Array(parts.dropFirst()) : parts).map {$0.lowercased()}
        let secretFiles:Set<String>=[".npmrc",".pypirc",".netrc",".git-credentials",".zsh_history",".bash_history",".python_history",".mysql_history",".node_repl_history",".sqlite_history",".irb_history",".lesshst"]
        let privateName=name.range(of:"password|credential|token|auth|secret|(?:encryption|decryption|signing|private|recovery)[ _.\\-]*(?:key|codes)",options:[.regularExpression,.caseInsensitive]) != nil
        if privateName || name.hasPrefix(".env") || secretFiles.contains(where:{name==$0 || name.hasPrefix($0+".")}) || secrets.intersection(secretParts).count>0 || ["pem","key","keychain","keychain-db"].contains(ext) {boundary="credentials"}
        else if parts.contains(".machine-audit") {boundary="audit"}
        else if !generated.intersection(parts).isEmpty {boundary="generated"}
        else if !appState.intersection(parts).isEmpty || parts.contains("Library") {boundary="app_state"}
        else if parts.contains(where:{["app","framework","bundle","photoslibrary","musiclibrary"].contains(URL(fileURLWithPath:$0).pathExtension.lowercased())}) {boundary="managed"}
        else if let first=parts.first,["System","usr","bin","sbin","private","opt","cores"].contains(first) {boundary="system"}
        return ["family":family,"role":roles[boundary] ?? "Unreviewed user data","boundary":boundary,"confidence":"0.35","basis":"Filename, file type and operational collection; file body not read","action":"Keep structure; review before any change"]
    }
}
