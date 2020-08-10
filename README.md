# bidrag-integration
![](https://github.com/navikt/bidrag-integration/workflows/build%20actions/badge.svg)

## Actions dealing with integrations

- cucumber-clone: clone a github cucumber project and add folder simple with a simple clone of the project which is beeing tested
- cucumber-latest: hent antall ok/feilede teststeg fra cucumber.json
- cucumber-move: flytter html for siste cumber-rapport til docs mappa for visining på github pages
- cucumber-status: skriver antall ok/felede testeg til github pages
- link-pages: lager linker av alle oppgitte sider til visning på github pages
- reports: Lager linker til alle cucumber-raporter til visning på github pages

## Release log

versjon | endringstype | beskrivelse
---|---|---
v2.0.0 | endret | refakturering av script og nye/endde inputs/outputs til/fra actions
v1.0.2 | endret | `cucumber-clone` default valued parameter to action: folder_nais_apps
v1.0.1 | endret | `cucumber-clone` added organization when cloning feature branch
v1 | opprettet | ny action: `cucumber-clone` som kloner et cucumber repository samt github repoet som testes
v1 | endret | portet fra https://github.com/navikt/bidrag-gh-pages
