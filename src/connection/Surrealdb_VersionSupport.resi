let minimumVersion: string
let maximumVersion: string
let isVersionSupportedRaw: (~version: string, ~minimum: string=?, ~until: string=?) => bool
let isVersionSupported: (string, ~minimum: string=?, ~until: string=?) => bool
