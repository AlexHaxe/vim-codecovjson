function! s:coverageFileName(file)
    let s:srcFolder = getcwd() . '/' . g:codecov_json_src . '/'
    let s:filePath = fnamemodify(a:file, ':p:h')
    let s:matched = match(s:filePath, s:srcFolder) == 0
    if !s:matched
        return a:file
    endif
    return strpart(a:file, strlen(s:srcFolder))
endfunction

let s:lastModification = 0

function! s:loadCoverageJson()
    let l:coverageFileName = getcwd() .'/' .g:codecov_json_filename
    let l:modificationTime = getftime(l:coverageFileName)
    if s:lastModification == l:modificationTime
        return
    endif
    let s:lastModification = l:modificationTime

    let l:coverageJson = ''
    for line in readfile(l:coverageFileName)
        let l:coverageJson = l:coverageJson . line
    endfor
    let l:coverageObj = maktaba#json#Parse(l:coverageJson)
    if empty(l:coverageObj)
        unlet s:lastModification
        unlet s:coverageData
        return
    endif
    let s:coverageData = l:coverageObj["coverage"]
endfunction

function! codecovjson#IsAvailable(file)
    let l:coverageName = s:coverageFileName(a:file)
    echomsg a:file
    echomsg l:coverageName
    call s:loadCoverageJson()
    if empty(s:coverageData)
        return false
    endif
    return has_key(s:coverageData, l:coverageName)
endfunction

function! codecovjson#GetCoverage(file)
    let l:coverageName = s:coverageFileName(a:file)
    call s:loadCoverageJson()
    if empty(s:coverageData)
        return {'covered': [],
                    \   'uncovered': [],
                    \   'partial': []}
    endif
    if empty(s:coverageData[l:coverageName])
        return {'covered': [],
                    \   'uncovered': [],
                    \   'partial': []}
    endif
    let l:coveredLines = []
    let l:uncoveredLines = []
    let l:partialLines = []
    let l:coverages = s:coverageData[l:coverageName]
    let index = 1
    while index < len(l:coverages)
        let line = index
        let index += 1
        let l:cover = string(l:coverages[line])
        if l:cover == '0'
            call add(uncoveredLines, line)
            continue
        endif
        if l:cover == '1'
            call add(coveredLines, line)
            continue
        endif
        call add(partialLines, line)
    endwhile

    return {'covered': l:coveredLines,
                \   'uncovered': uncoveredLines,
                \   'partial': partialLines}
endfunction

