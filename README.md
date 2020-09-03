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

versjon | endringstype | beskrivelse
---|---|---
v4.1.0 | opprettet | `cucumber-clone-tags` clones `bidrag-backend-cucumber` and all applications from cucumber tags
v4.0.0 | endret | `cucumber-clone` extra clones to prepare for cucumber integration testing 
v3.0.3 | endret | `reports` reports are added in a html table
v3.0.2 | endret | `link-pages` correct shell variable name
v3.0.1 | endret | `cucumber-latest` output er samme som innhold i bidrag-dev.json
v3.0.0 | endret | `cucumber-move` ingen output, men oppretter bidrag-dev.json med info
v2.0.0 | endret | refakturering av script og nye/endde inputs/outputs til/fra actions
v1.0.2 | endret | `cucumber-clone` default valued parameter to action: folder_nais_apps
v1.0.1 | endret | `cucumber-clone` added organization when cloning feature branch
v1 | opprettet | ny action: `cucumber-clone` som kloner et cucumber repository samt github repoet som testes
v1 | endret | portet fra https://github.com/navikt/bidrag-gh-pages
