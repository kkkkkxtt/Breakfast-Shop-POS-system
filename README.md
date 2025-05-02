# Breakfast-Shop-POS-system
This project demonstrates a simple Point-of-Sale (POS) system for a breakfast shop, developed using assembly language. It includes features such as menu display, order processing, and file handling for menu view. Designed as a learning project to explore low-level programming and system-level file operations

# Breakfast Shop POS System

![Assembly Language](https://img.shields.io/badge/Language-Assembly-blueviolet)
![License](https://img.shields.io/badge/License-MIT-green)

A Point of Sale system for a breakfast shop written in x86 Assembly.

## Project Structure

```
Breakfast-Shop-POS-system/
├── src/
│   ├── breakfastshop_pos_system.asm  # Main assembly source
│   └── menu.txt                     # Menu data file
├── LICENSE
└── README.md
```

## Features

- **Order Management**:
  - View menu items
  - Add items to order
  - Calculate total

- **Menu Management**:
  - Add/delete items
  - Update prices
  - Persistent storage

## Requirements

- NASM assembler
- GNU linker (ld)
- Linux or WSL environment

## Installation

```bash
# Clone the repository
git clone https://github.com/kkkkkxtt/Breakfast-Shop-POS-system.git
cd Breakfast-Shop-POS-system

# Build and run
cd src
nasm -f elf32 breakfastshop_pos_system.asm -o pos.o
ld -m elf_i386 pos.o -o pos
./pos
```

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
