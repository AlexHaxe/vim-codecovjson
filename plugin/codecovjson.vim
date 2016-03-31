let g:registry = maktaba#extension#GetRegistry('coverage')
call g:registry.AddExtension({
            \    'name': 'codecov_json_provider',
            \    'GetCoverage': function('codecovjson#GetCoverage'),
            \    'IsAvailable': function('codecovjson#IsAvailable')})

let g:codecov_json_src = 'src'
let g:codecov_json_filename = 'coverage.json'
