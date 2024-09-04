# Mangrove Resilience and Storm Surge Protection in the Gulf of Gonave 

This project simulates the impact of mangrove forests on storm surge dynamics using the ADCIRC (Advanced Circulation) model in the Gulf of Gonave (Golfe de la Gonave), Haiti. The project aims to assess the effectiveness of mangrove protection in mitigating storm surge impacts in this coastal regions, and focuses on the Grand-Pierre Bay Mangrove Forest as an example. 

## Table of Contents

- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Data Requirements](#data-requirements)
- [Configuration](#configuration)
- [Running Simulations](#running-simulations)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Introduction

Mangroves play a crucial role in protecting coastal areas from storm surges. This project uses ADCIRC to model and analyze how different mangrove coverage and climate change scenarios affect storm surge levels in the Gulf of Gonave, and the hydrodynamics in the Grand-Pierre Bay mangrove forest. The simulations can inform coastal management, as well as adaptation and conservation strategies.

## Project Structure

- analysis: scripts and notebooks for visualization and analysis.
- ch2-resilience: final runs dedicated to studying the resilience of mangroves.
- ch3-protection: final runs dedicated to studying the protection potential of mangroves.
- datasets: contains any dataset used (meshes, bathymetry, mangrove cover maps, etc.)
- docs: background info and documentation
- scripts: scripts used for running and analyzing simulations.
- staging: where new ideas are tested and implemented.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Installation

### Prerequisites

Ensure you have the following software installed:

- [ADCIRC](https://adcirc.org/)
- Fortran compiler (e.g., `gfortran`)
- Python 3.x
- Required Python packages (listed in `requirements.txt`)

Scripts for automation and visualization:
- Kalpana 
- adcircpy

### Installation Steps

1. **Clone the repository:**

    ```bash
    git clone https://github.com/aesgeorges/LaGonaveFM.git
    cd LaGonaveFM
    ```

2. **Install Python dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

3. **Compile ADCIRC (if necessary):**

    Follow the [ADCIRC installation guide](https://adcirc.org/installation/) to compile the model. Or my guide in docs/adcirc_installation.md

4. **Install Tools:**
    Kalpana: Available at (https://github.com/ccht-ncsu/Kalpana).
    ake sure to install in same parent directory as LaGonaveFM

    adcircpy: ```bash pip install adcircpy```

## Configuration

Modify and run setup.ipynb to configure your runs. 
[More details soon...]

## Running Simulations

Navigate to your specific run. If needed, initialize files using init.sh
Then modify and run using either run.sh, slurmcold.sh or slurmhot.sh based on need.

## Monitoring and Logging
Simulations can be monitored by viewing the log files in the logs/ directory:

    tail -f logs/stage/id.log

Where stage is the current project stage you are working in (staging, chapter2 or chapter3), and id is your run id. 

Logs of every runs and their configuration file (fort.15) are recorded under that same path. 

## Contributing

While this is a work in progress for my thesis, contributions are welcome! Please follow these steps to contribute:


## Contact
For any questions or suggestions:

Alexandre E. S. Georges - alexandre_georges@berkeley.edu

GitHub - https://github.com/aesgeorges


## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
