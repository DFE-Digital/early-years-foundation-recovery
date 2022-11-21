# Diagrams

The [Unified Modelling Language][plantuml]™ (UML®) is a standard visual modelling language.

## Setup

- `SVG` versions are automatically generate when the documentation server starts.
- `PNG` versions can be built using `./bin/docker-uml`.

Alternatively, you can integrate a [UML server][server] with your IDE:

- locally inside [Docker][docker]
- using the public [UML sandbox][sandbox] to create images and debug code.

Options:

1. [Sublime Text][sublime]
2. [VS Code][vscode]
3. [Microsoft Visio][visio]


## Diagrams

<!--
### (WIP) Application UML

![Application UML](application.svg "Application")
-->

### Entity Relationship Diagram

![Entity Relationship](erd.svg "Database")

### Docker Compose Environments

![Docker UML](docker.svg "Docker")

### Deployment Workflows

![Deployment UML](deployment.svg "Deployment")


---

[plantuml]: https://plantuml.com/creole
[sandbox]: https://www.plantuml.com/plantuml/uml
[server]: https://github.com/plantuml/plantuml-server
[docker]: https://hub.docker.com/r/plantuml/plantuml-server
[sublime]: https://github.com/evandrocoan/PlantUmlDiagrams
[vscode]: https://github.com/qjebbs/vscode-plantuml
[visio]: https://products.office.com/en/visio/flowchart-software
