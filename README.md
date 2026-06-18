# 📡 Morse Code Converter — x86-64 Assembly (MASM)

A terminal-based program written in **x86-64 Assembly (MASM syntax)** that reads plain text from the console and outputs its International Morse Code equivalent — character by character, in real time.

Built from scratch as a hands-on learning project to develop low-level programming skills for **reverse engineering** and **offensive security**.

---

## 🎯 Purpose

This project was built with one goal: **understand the machine**.

Reverse engineering and offensive security require reading, analyzing, and reasoning about assembly code at the instruction level. Writing a real, working program in ASM — not just reading it — forces you to think like the CPU: managing registers manually, making raw syscalls, and controlling every byte of data flow.

This converter is proof of that practice.

---

## ✨ Features

- Reads plain text from the terminal via `ReadConsoleA`
- Outputs the Morse code equivalent via `WriteConsoleA`
- Supports all 26 letters (A–Z), case handling via ASCII arithmetic
- Uses a **QWORD pointer table** (`morseTable`) for O(1) character lookup
- No standard library — all I/O done through Win32 console API syscalls directly
- Properly manages the x86-64 **shadow space** (32-byte stack alignment) on every call

---

## 🛠️ Tech Stack

| Layer | Detail |
|---|---|
| Language | x86-64 Assembly |
| Syntax | MASM (Microsoft Macro Assembler) |
| Platform | Windows (Win32 Console API) |
| API calls | `GetStdHandle`, `ReadConsoleA`, `WriteConsoleA`, `GetConsoleMode`, `SetConsoleMode` |

---

## 🚀 Build & Run

### Prerequisites

- Visual Studio with MASM (`ml64.exe`) installed, **or**
- [MASM32 SDK](http://www.masm32.com/)

### Assemble & Link

```bash
ml64 morse.asm /link /subsystem:console /entry:main kernel32.lib
```

### Run

```
morse.exe
Enter the plain text: HELLO
.... . .-.. .-.. ---
```

---

## 🧠 How It Works

### 1. Morse Lookup Table

Each letter A–Z is stored as a 4-byte string padded with spaces:

```asm
mA  BYTE ".-  ", 0
mB  BYTE "-...", 0
...
morseTable QWORD OFFSET mA, OFFSET mB, ...  ; pointer table
```

### 2. Character-to-Index Arithmetic

Each character is mapped to its table index using simple ASCII math:

```asm
sub  al, 41h    ; al = char - 'A'  →  index (0 = A, 1 = B, ...)
mov  bl, 5      ; each entry is 5 bytes (4 chars + null)
mul  bl         ; offset = index * 5
movzx rbx, ax
mov  rcx, morseTable
add  rcx, rbx   ; rcx now points to the correct Morse string
```

### 3. Win32 Console I/O

All I/O goes through the Win32 API directly — no CRT, no printf:

```asm
; Output
mov rcx, STD_OUTPUT_HANDLE
call GetStdHandle
mov rcx, rax
call WriteConsoleA

; Input
mov ecx, STD_INPUT_HANDLE
call GetStdHandle
call ReadConsoleA
```

### 4. Stack Discipline

Every `call` properly allocates 32 bytes of **shadow space** and realigns the stack per the x86-64 Windows calling convention:

```asm
sub rsp, 40    ; 32-byte shadow + 8-byte alignment
call SomeFunc
add rsp, 40
```

---

## 🔗 Connection to Reverse Engineering & Offensive Security

Writing this project at the instruction level directly maps to real RE and security skills:

| This Project | RE / Offensive Security Application |
|---|---|
| Win32 API calls via registers | Reading API calls in disassemblers (Ghidra, IDA Pro) |
| Manual stack management | Understanding stack frames, return addresses, calling conventions |
| Pointer arithmetic on `morseTable` | Reading lookup tables and jump tables in binaries |
| `sub rsp, 40` shadow space | Recognizing function prologues during static analysis |
| `cmp al, 0Dh` / `je done` | Tracing control flow, identifying loop terminators |
| Raw `GetStdHandle` / `ReadConsoleA` | Identifying I/O patterns in malware samples |

You can't reverse what you don't understand at the instruction level. Writing it first closes that gap.

---

## 📁 Project Structure

```
morse-asm/
├── morse.asm        ; Full source — data, logic, I/O, main loop
└── README.md        ; This file
```

---

## 📜 License

MIT — free to use, study, and learn from.

---

> *"To understand the enemy's code, you must first write your own."*
