# DAC for STM32F407G-DISC1
Generate a waveform using a lut, timer interrupt, and the dac on you discovery board. This project uses a minimal setup which only includes the register definitions from St and the CMSIS core. It is helpful to have an oscilloscope around to view the waveform output.

## Required Tools
* [GNU Make](https://www.gnu.org/software/make/)
* [GNU ARM Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
* [St-Link Flash Utility](https://github.com/texane/stlink)
* [STM32F407G-DISC1 Development Board](https://www.st.com/en/evaluation-tools/stm32f4discovery.html)
* (Optional) Ocilloscope for viewing output

## Compiling Instructions
> Make sure your discovery board is plugged into your computer, and that you have the required tools installed. Then use your shell to clone the git repository and compile/flash your board.
```
git clone https://github.com/mkrolbass/dac.git
cd dac
make flash
```
