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

## Output Example

### System Menu
<div align="center">
  <img src="https://github.com/user-attachments/assets/8dafb0aa-5710-43a3-802b-87ec17a3c6ca" width="50%">
</div>

### Order
<div align="center">
  <img src="https://github.com/user-attachments/assets/6970513b-c9ba-4b6d-b3d6-2221c60312a2" width="50%">
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/fed5e4a2-8d32-4365-9726-51955d389302" width="50%">
</div>

### Modification
<div align="center">
  <img src="https://github.com/user-attachments/assets/f0df31e5-8045-48ad-8733-eedc429379a1" width="50%">
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/03770c2e-f40f-4d4a-a9ba-08d80be9c8c7" width="50%">
</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/9afa5507-1d9d-401b-9de0-36463edcc622" width="50%">
</div>


## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
