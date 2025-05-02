; POS System for Breakfast Shop

section .data
    ; File descriptors and buffers
    menu_file    db "menu.txt", 0        ; Name of the menu file
    temp_file    db "temp.txt", 0        ; Temporary file for menu modifications
    menu_fd      dd 0                    ; File descriptor for menu file
    buffer       times 512 db 0          ; Buffer to read/write file data
    buf_len      equ $ - buffer          ; Length of the buffer

    ; Main Menu Prompts
    prompt_pos   db  "=============================", 10, "POS System for Breakfast Shop", 10, "=============================", 10, 0
    prompt_pos_len equ $ - prompt_pos    ; Welcome banner for POS system
    prompt_operations db "Welcome to Breakfast Shop! ", 10, "What Operations would you like to do?", 10, 0
    prompt_operations_len equ $ - prompt_operations
    prompt_operations_choice db "0. Quit  1. Order  2. Modify Menu ", 10, 0  ; Main menu options
    prompt_operations_choice_len equ $ - prompt_operations_choice

    ; Order Prompts
    prompt_menu  db "=====================", 10, "	Menu", 10, "=====================", 10, 0
    prompt_menu_len equ $ - prompt_menu  ; Header for displaying the menu
    menu_seperator  db "=====================", 10,0
    menu_seperator_len equ $ - menu_seperator
    prompt_order db  "Enter item name to order or type 0 to finish order: ", 0  ; Prompt for item input
    prompt_order_len equ $ - prompt_order
    prompt_qty   db "Enter quantity: ", 0  ; Prompt for quantity input
    prompt_qty_len equ $ - prompt_qty
    newline      db 10, 0                ; Newline character
    rm_string    db " RM"                ; Currency suffix for display
    comma        db ",", 0               ; Comma separator for file format
    error_msg    db "Item not found in menu!", 10, 0  ; Error message for invalid item
    error_msg_len equ $ - error_msg

    ; Modify Menu Prompts
    prompt_modify_menu db  "Current menu:", 10, 0  ; Header for modify menu section
    prompt_modify_menu_len equ $ - prompt_modify_menu
    prompt_modified_choice db "=====================", 10, "0. Return to Main Menu  1. Add Item  2. Delete Item  3. Update Price",10, 0
    prompt_modified_choice_len equ $ - prompt_modified_choice  ; Modification options
    prompt_modified_item db  "------------------", 10,"Enter new item name: ", 0  ; Prompt for new item name
    prompt_modified_item_len equ $ - prompt_modified_item
    prompt_modified_price db "Enter item price: ", 0  ; Prompt for item price
    prompt_modified_price_len equ $ - prompt_modified_price
    prompt_deleted_item db  "--------------------------", 10, "Enter item name to delete: ", 0
    prompt_deleted_item_len equ $ - prompt_deleted_item
    prompt_success_add db "Item added successfully!", 10, 0  ; Success message for adding item
    prompt_success_add_len equ $ - prompt_success_add
    prompt_success_delete db "Item deleted successfully!", 10, 0  ; Success message for deleting item
    prompt_success_delete_len equ $ - prompt_success_delete
    prompt_item db  "--------------------------", 10, "Enter item name to update: ", 0  ; Prompt for item to update
    prompt_item_len equ $ - prompt_item
    prompt_item_price db "Enter new price: ", 0  ; Prompt for new price
    prompt_item_price_len equ $ - prompt_item_price
    prompt_success_update db "Price updated successfully!", 10, 0  ; Success message for updating price
    prompt_success_update_len equ $ - prompt_success_update
    not_found_msg db "Item not found in menu!", 10, 0  ; Error message for item not found
    not_found_msg_len equ $ - not_found_msg
    invalid_price_msg db "Invalid price entered!", 10, 0  ; Error for invalid price input
    invalid_price_msg_len equ $ - invalid_price_msg

    ; Prices and totals
    total        dd 0                    ; Running total for the order
    total_msg    db "---------------------", 10, "Total Amount: RM", 0  ; Total amount display
    total_msg_len equ $ - total_msg
    total_str    times 10 db 0           ; Buffer for total as string
    total_str_len equ $ - total_str
    payment_msg  db "---------------------", 10, "Payment Successful, Thank you!",10,10, 0  ; Payment confirmation
    payment_msg_len equ $ - payment_msg

    ; Input buffer
    input        times 10 db 0           ; Buffer for user input
    input_len    equ $ - input

    ; Item information
    item_prices  times 50 dd 0           ; Array of item prices (up to 50 items)
    item_names   times 50 times 20 db 0  ; Array of item names (50 items, 20 chars each)
    temp_names   times 20 db 0           ; Temporary buffer for item names

section .bss
    ; Uninitialized data (reserved memory)
    qty          resd 1                  ; Quantity of an item ordered
    main_menu_choice resd 1              ; User's main menu choice
    modification_menu_choice resd 1      ; User's modification menu choice
    new_item     resb 50                 ; Buffer for new item name
    new_price    resb 10                 ; Buffer for new price
    temp_buffer  resb 512                ; Temporary buffer for file operations
    ordered_items resd 10                ; Array of quantities for ordered items
    item_count   resd 1                  ; Number of items in the menu
    order_index  resd 1                  ; Index for tracking ordered items
    read_bytes   resd 1                  ; Number of bytes read from file
    choice       resd 1                  ; General-purpose choice variable
    price        resd 1                  ; Temporary price storage
    item_index   resd 1                  ; Index of found item
    item_found   resb 1                  ; Flag indicating if item was found
    input_buf    resb 100                ; Buffer for order input
    input_len_var resd 1                 ; Length of input buffer content
    name_len     resd 1                  ; Length of item name
    price_len    resd 1                  ; Length of price string
    temp_fd      resd 1                  ; File descriptor for temp file
    line_buffer  resb 100                ; Buffer for processing lines
    current_pos  resd 1                  ; Current position in buffer
    line_start   resd 1                  ; Start of current line
    line_length  resd 1                  ; Length of current line

section .text
    global _start

_start:
    ; Program entry point: Initialize variables and load menu
    mov dword [item_count], 0
    mov dword [total], 0
    call load_menu

main_menu:
    ; Display main menu and handle user input
    mov eax, 4                   ; Syscall: write
    mov ebx, 1                   ; File descriptor: stdout
    mov ecx, prompt_pos          ; Display POS banner
    mov edx, prompt_pos_len
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_operations   ; Display welcome message
    mov edx, prompt_operations_len
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_operations_choice  ; Display menu options
    mov edx, prompt_operations_choice_len
    int 0x80
    
    mov eax, 3                   ; Syscall: read
    mov ebx, 0                   ; File descriptor: stdin
    mov ecx, input               ; Read user choice
    mov edx, input_len
    int 0x80
    
    movzx eax, byte [input]      ; Convert ASCII choice to integer
    sub eax, '0'
    mov [main_menu_choice], eax
    
    cmp dword [main_menu_choice], 0  ; Check user choice
    je exit                      ; 0: Exit program
    cmp dword [main_menu_choice], 1
    je order_menu                ; 1: Go to order menu
    cmp dword [main_menu_choice], 2
    je modify_menu               ; 2: Go to modify menu
    jmp main_menu                ; Invalid choice: loop back

order_menu:
    ; Handle ordering process
    call display_menu            ; Show current menu
    mov dword [total], 0         ; Reset total
    mov dword [order_index], 0   ; Reset order index

    mov eax, 4
    mov ebx, 1
    mov ecx, menu_seperator      ; Display separator
    mov edx, menu_seperator_len
    int 0x80

order_loop:
    ; Loop to take orders
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_order        ; Prompt for item name
    mov edx, prompt_order_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf           ; Read item name
    mov edx, 100
    int 0x80
    
    mov [input_len_var], eax     ; Store input length
    
    cmp byte [input_buf], '0'    ; Check if user wants to finish (0)
    je calculate_total
    
    dec dword [input_len_var]    ; Remove newline from length
    mov ecx, [input_len_var]
    mov byte [input_buf + ecx], 0  ; Null-terminate input
    
    mov byte [item_found], 0     ; Reset item found flag
    call find_item               ; Look for item in menu
    
    cmp byte [item_found], 0     ; Check if item was found
    je item_not_found_error
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_qty          ; Prompt for quantity
    mov edx, prompt_qty_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, input               ; Read quantity
    mov edx, input_len
    int 0x80
    
    movzx ecx, byte [input]      ; Convert quantity to integer
    sub ecx, '0'
    mov [qty], ecx
    
    mov edx, [item_index]        ; Calculate cost: price * quantity
    mov eax, [item_prices + edx*4]
    mul dword [qty]
    add [total], eax             ; Add to total
    
    mov ebx, [order_index]       ; Store quantity in ordered_items array
    mov ecx, [qty]
    mov [ordered_items + ebx*4], ecx
    inc dword [order_index]      ; Increment order index
    
    jmp order_loop               ; Continue ordering

item_not_found_error:
    ; Handle case where item isn't found
    mov eax, 4
    mov ebx, 1
    mov ecx, error_msg           ; Display error message
    mov edx, error_msg_len
    int 0x80
    jmp order_loop               ; Back to order loop

calculate_total:
    ; Display the total and complete the order
    mov eax, 4
    mov ebx, 1
    mov ecx, total_msg           ; Show total message
    mov edx, total_msg_len
    int 0x80
    
    mov eax, [total]             ; Convert total to string
    mov esi, total_str + 9
    mov byte [esi], 0            ; Null-terminate
    dec esi
    
    test eax, eax                ; Handle case where total is 0
    jnz convert_total
    mov byte [esi], '0'
    dec esi
    jmp display_total_str
    
convert_total:
    ; Convert integer total to string
    test eax, eax
    jz display_total_str
    xor edx, edx
    mov ecx, 10
    div ecx                      ; Divide by 10, remainder in edx
    add dl, '0'                  ; Convert remainder to ASCII
    mov [esi], dl
    dec esi
    jmp convert_total

display_total_str:
    ; Display the total string
    mov eax, 4
    mov ebx, 1
    lea ecx, [esi + 1]           ; Start of string
    mov edx, total_str + 9
    sub edx, esi                 ; Calculate length
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, newline             ; Newline
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, payment_msg         ; Payment success message
    mov edx, payment_msg_len
    int 0x80
    
    jmp main_menu                ; Return to main menu

modify_menu:
    ; Handle menu modification options
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_modify_menu  ; Show current menu header
    mov edx, prompt_modify_menu_len
    int 0x80
    
    call display_menu            ; Display current menu
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_modified_choice  ; Show modification options
    mov edx, prompt_modified_choice_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, input               ; Read user choice
    mov edx, input_len
    int 0x80
    
    movzx eax, byte [input]      ; Convert choice to integer
    sub eax, '0'
    mov [modification_menu_choice], eax
    
    cmp dword [modification_menu_choice], 0  ; Check choice
    je main_menu                 ; 0: Back to main menu
    cmp dword [modification_menu_choice], 1
    je add_item                  ; 1: Add item
    cmp dword [modification_menu_choice], 2
    je delete_item               ; 2: Delete item
    cmp dword [modification_menu_choice], 3
    je update_price              ; 3: Update price
    jmp modify_menu              ; Invalid choice: loop back

add_item:
    ; Add a new item to the menu
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_modified_item  ; Prompt for item name
    mov edx, prompt_modified_item_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, new_item            ; Read item name
    mov edx, 50
    int 0x80
    
    dec eax                      ; Adjust for newline
    mov [name_len], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_modified_price  ; Prompt for price
    mov edx, prompt_modified_price_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, new_price           ; Read price
    mov edx, 10
    int 0x80
    
    dec eax                      ; Adjust for newline
    mov [price_len], eax
    
    mov eax, 5                   ; Syscall: open (read mode)
    mov ebx, menu_file
    mov ecx, 0                   ; O_RDONLY
    int 0x80
    
    mov [menu_fd], eax           ; Save file descriptor
    mov eax, 3                   ; Read menu file into buffer
    mov ebx, [menu_fd]
    mov ecx, buffer
    mov edx, buf_len
    int 0x80
    
    mov [read_bytes], eax        ; Save number of bytes read
    mov eax, 6                   ; Close file
    mov ebx, [menu_fd]
    int 0x80
    
    mov eax, 5                   ; Syscall: open (write mode)
    mov ebx, menu_file
    mov ecx, 65                  ; O_WRONLY | O_CREAT
    mov edx, 0644o               ; File permissions
    int 0x80
    
    mov [menu_fd], eax           ; Save file descriptor
    mov eax, 4                   ; Write existing menu content
    mov ebx, [menu_fd]
    mov ecx, buffer
    mov edx, [read_bytes]
    int 0x80
    
    mov eax, 4                   ; Write new item name
    mov ebx, [menu_fd]
    mov ecx, new_item
    mov edx, [name_len]
    int 0x80
    
    mov eax, 4                   ; Write comma separator
    mov ebx, [menu_fd]
    mov ecx, comma
    mov edx, 1
    int 0x80
    
    mov eax, 4                   ; Write new price
    mov ebx, [menu_fd]
    mov ecx, new_price
    mov edx, [price_len]
    int 0x80
    
    mov eax, 4                   ; Write newline
    mov ebx, [menu_fd]
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 6                   ; Close file
    mov ebx, [menu_fd]
    int 0x80
    
    mov eax, 4                   ; Display success message
    mov ebx, 1
    mov ecx, prompt_success_add
    mov edx, prompt_success_add_len
    int 0x80
    
    call load_menu               ; Reload menu into memory
    jmp main_menu

delete_item:
    ; Delete an item from the menu
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_deleted_item  ; Prompt for item to delete
    mov edx, prompt_deleted_item_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, new_item            ; Read item name
    mov edx, 50
    int 0x80
    
    dec eax                      ; Adjust for newline
    mov [name_len], eax
    
    mov ebx, eax
    mov byte [new_item + ebx], 0  ; Null-terminate input
    
    mov eax, 5                   ; Open menu file for reading
    mov ebx, menu_file
    mov ecx, 0                   ; O_RDONLY
    int 0x80
    
    test eax, eax
    js file_error                ; Jump if file open fails
    mov [menu_fd], eax
    
    mov eax, 3                   ; Read menu into buffer
    mov ebx, [menu_fd]
    mov ecx, buffer
    mov edx, buf_len
    int 0x80
    mov [read_bytes], eax
    
    mov eax, 6                   ; Close menu file
    mov ebx, [menu_fd]
    int 0x80
    
    mov eax, 5                   ; Open temp file for writing
    mov ebx, temp_file
    mov ecx, 0x442               ; O_WRONLY | O_CREAT | O_TRUNC
    mov edx, 0644o               ; Permissions
    int 0x80
    mov [temp_fd], eax
    
    mov dword [current_pos], 0   ; Initialize buffer position
    mov byte [item_found], 0     ; Reset item found flag
    
process_buffer_del:
    ; Process buffer line by line for deletion
    mov eax, [current_pos]
    cmp eax, [read_bytes]
    jae finish_processing_del    ; Done if end of buffer reached
    
    mov [line_start], eax        ; Mark start of current line
    
find_line_end_del:
    ; Find the end of the current line
    mov ebx, [current_pos]
    cmp ebx, [read_bytes]
    jae line_end_found_del
    
    mov ecx, buffer
    add ecx, ebx
    cmp byte [ecx], 0x0A         ; Check for newline
    je line_end_found_del
    inc dword [current_pos]
    jmp find_line_end_del
    
line_end_found_del:
    mov eax, [current_pos]
    sub eax, [line_start]
    mov [line_length], eax       ; Calculate line length
    
    mov ebx, [current_pos]
    cmp ebx, [read_bytes]
    jae no_newline_inc_del
    inc dword [current_pos]      ; Move past newline
    
no_newline_inc_del:
    ; Copy line to line_buffer
    mov esi, buffer
    add esi, [line_start]
    mov edi, line_buffer
    mov ecx, [line_length]
    rep movsb
    
    mov byte [line_buffer + eax], 0  ; Null-terminate line
    
    call check_line              ; Check if this is the item to delete
    
    cmp eax, 1                   ; If item matches, skip it
    je skip_line_del
    
    mov eax, 4                   ; Write non-matching line to temp file
    mov ebx, [temp_fd]
    mov ecx, buffer
    add ecx, [line_start]
    mov edx, [line_length]
    int 0x80
    
    mov eax, [line_start]
    add eax, [line_length]
    cmp eax, [read_bytes]
    jae skip_line_del
    
    mov eax, 4                   ; Write newline
    mov ebx, [temp_fd]
    mov ecx, newline
    mov edx, 1
    int 0x80
    
skip_line_del:
    jmp process_buffer_del       ; Process next line
    
finish_processing_del:
    ; Finalize deletion
    mov eax, 6                   ; Close temp file
    mov ebx, [temp_fd]
    int 0x80
    
    cmp byte [item_found], 0     ; Check if item was found
    je item_not_found_del
    
    mov eax, 38                  ; Syscall: rename temp to menu file
    mov ebx, temp_file
    mov ecx, menu_file
    int 0x80
    
    mov eax, 4                   ; Display success message
    mov ebx, 1
    mov ecx, prompt_success_delete
    mov edx, prompt_success_delete_len
    int 0x80
    
    call load_menu               ; Reload updated menu
    jmp main_menu
    
item_not_found_del:
    ; Handle item not found case
    mov eax, 10                  ; Syscall: unlink (delete temp file)
    mov ebx, temp_file
    int 0x80
    
    mov eax, 4                   ; Display not found message
    mov ebx, 1
    mov ecx, not_found_msg
    mov edx, not_found_msg_len
    int 0x80
    jmp main_menu

file_error:
    ; Handle file operation errors
    mov eax, 4
    mov ebx, 1
    mov ecx, not_found_msg       ; Reuse not found message for simplicity
    mov edx, not_found_msg_len
    int 0x80
    jmp main_menu

update_price:
    ; Update the price of an existing item
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_item         ; Prompt for item name
    mov edx, prompt_item_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, new_item            ; Read item name
    mov edx, 50
    int 0x80
    dec eax
    mov [name_len], eax
    
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_item_price   ; Prompt for new price
    mov edx, prompt_item_price_len
    int 0x80
    
    mov eax, 3
    mov ebx, 0
    mov ecx, new_price           ; Read new price
    mov edx, 10
    int 0x80
    dec eax
    mov [price_len], eax
    
    call validate_price          ; Check if price is valid
    cmp eax, 0
    je invalid_price_exit
    
    mov eax, 5                   ; Open menu file for reading
    mov ebx, menu_file
    mov ecx, 0                   ; O_RDONLY
    int 0x80
    test eax, eax
    js file_error
    mov [menu_fd], eax
    
    mov eax, 3                   ; Read menu into buffer
    mov ebx, [menu_fd]
    mov ecx, buffer
    mov edx, buf_len
    int 0x80
    mov [read_bytes], eax
    
    mov eax, 6                   ; Close menu file
    mov ebx, [menu_fd]
    int 0x80
    
    mov eax, 5                   ; Open temp file for writing
    mov ebx, temp_file
    mov ecx, 0x442               ; O_WRONLY | O_CREAT | O_TRUNC
    mov edx, 0644o
    int 0x80
    mov [temp_fd], eax
    
    mov dword [current_pos], 0   ; Initialize buffer position
    mov byte [item_found], 0     ; Reset item found flag
    
process_buffer_upd:
    ; Process buffer line by line for price update
    mov eax, [current_pos]
    cmp eax, [read_bytes]
    jae finish_processing_upd
    
    mov [line_start], eax        ; Mark line start
    
find_line_end_upd:
    ; Find end of current line
    mov ebx, [current_pos]
    cmp ebx, [read_bytes]
    jae line_end_found_upd
    
    mov ecx, buffer
    add ecx, ebx
    cmp byte [ecx], 0x0A         ; Check for newline
    je line_end_found_upd
    inc dword [current_pos]
    jmp find_line_end_upd
    
line_end_found_upd:
    mov eax, [current_pos]
    sub eax, [line_start]
    mov [line_length], eax       ; Calculate line length
    inc dword [current_pos]      ; Move past newline
    
    mov esi, buffer
    add esi, [line_start]
    mov edi, line_buffer
    mov ecx, [line_length]
    rep movsb
    
    mov byte [line_buffer + eax], 0  ; Null-terminate line
    call check_line              ; Check if this is the item
    
    cmp byte [item_found], 1     ; If item found, update price
    je update_price_in_line
    
    mov eax, 4                   ; Write unchanged line to temp file
    mov ebx, [temp_fd]
    mov ecx, buffer
    add ecx, [line_start]
    mov edx, [line_length]
    int 0x80
    
write_newline_upd:
    mov eax, [line_start]
    add eax, [line_length]
    cmp eax, [read_bytes]
    jae process_buffer_upd
    
    mov eax, 4                   ; Write newline
    mov ebx, [temp_fd]
    mov ecx, newline
    mov edx, 1
    int 0x80
    jmp process_buffer_upd

update_price_in_line:
    ; Write updated price for matching item
    mov byte [item_found], 2     ; Mark as processed
    mov eax, 4                   ; Write item name and comma
    mov ebx, [temp_fd]
    mov ecx, buffer
    add ecx, [line_start]
    mov edx, [name_len]
    inc edx                      ; Include comma
    int 0x80
    
    mov eax, 4                   ; Write new price
    mov ebx, [temp_fd]
    mov ecx, new_price
    mov edx, [price_len]
    int 0x80
    jmp write_newline_upd

finish_processing_upd:
    ; Finalize price update
    mov eax, 6                   ; Close temp file
    mov ebx, [temp_fd]
    int 0x80
    
    cmp byte [item_found], 0     ; Check if item was found
    je item_not_found_upd
    
    mov eax, 38                  ; Rename temp file to menu file
    mov ebx, temp_file
    mov ecx, menu_file
    int 0x80
    
    mov eax, 4                   ; Display success message
    mov ebx, 1
    mov ecx, prompt_success_update
    mov edx, prompt_success_update_len
    int 0x80
    
    call load_menu               ; Reload updated menu
    jmp main_menu
    
item_not_found_upd:
    ; Handle item not found case
    mov eax, 10                  ; Delete temp file
    mov ebx, temp_file
    int 0x80
    
    mov eax, 4                   ; Display not found message
    mov ebx, 1
    mov ecx, not_found_msg
    mov edx, not_found_msg_len
    int 0x80
    jmp main_menu

invalid_price_exit:
    ; Handle invalid price input
    mov eax, 4
    mov ebx, 1
    mov ecx, invalid_price_msg
    mov edx, invalid_price_msg_len
    int 0x80
    jmp main_menu

validate_price:
    ; Validate that price input is numeric
    mov ecx, 0

check_digit:
    cmp ecx, [price_len]
    je price_valid               ; All digits checked
    mov bl, [new_price + ecx]
    cmp bl, '0'                  ; Check if less than '0'
    jl price_invalid
    cmp bl, '9'                  ; Check if greater than '9'
    jg price_invalid
    inc ecx
    jmp check_digit

price_valid:
    mov eax, 1                   ; Return 1 (valid)
    ret

price_invalid:
    xor eax, eax                 ; Return 0 (invalid)
    ret

check_line:
    ; Check if current line matches the item name
    mov ecx, 0

find_comma_del:
    cmp byte [line_buffer + ecx], ','  ; Look for comma separator
    je found_comma_del
    inc ecx
    cmp ecx, [line_length]
    jb find_comma_del
    xor eax, eax                 ; No match
    ret

found_comma_del:
    cmp ecx, [name_len]          ; Compare name length
    jne names_differ
    
    mov esi, 0

compare_loop:
    mov dl, byte [line_buffer + esi]
    mov dh, byte [new_item + esi]
    cmp dl, dh                   ; Compare characters
    jne names_differ
    inc esi
    cmp esi, ecx
    jb compare_loop
    
    mov byte [item_found], 1     ; Item found
    mov eax, 1
    ret

names_differ:
    xor eax, eax                 ; No match
    ret

load_menu:
    ; Load menu from file into memory
    mov eax, 5                   ; Open menu file
    mov ebx, menu_file
    mov ecx, 0                   ; O_RDONLY
    mov edx, 0777                ; Permissions
    int 0x80
    
    mov [menu_fd], eax
    mov eax, 3                   ; Read file into buffer
    mov ebx, [menu_fd]
    mov ecx, buffer
    mov edx, buf_len
    int 0x80
    
    mov [read_bytes], eax
    mov eax, 6                   ; Close file
    mov ebx, [menu_fd]
    int 0x80
    
    call parse_menu              ; Parse buffer into item arrays
    ret

save_menu:
    ; Save menu from memory to file
    mov eax, 5                   ; Open menu file for writing
    mov ebx, menu_file
    mov ecx, 0102o               ; O_WRONLY | O_CREAT
    mov edx, 0666o               ; Permissions
    int 0x80
    
    mov [menu_fd], eax
    mov ecx, 512
    mov edi, temp_buffer
    xor eax, eax
    rep stosb                    ; Clear temp buffer
    
    mov edi, temp_buffer         ; Build menu string in temp buffer
    mov ecx, 0                   ; Buffer offset
    mov ebx, 0                   ; Item index

save_menu_loop:
    cmp ebx, [item_count]
    jge save_menu_write          ; Done if all items processed
    
    mov esi, ebx
    imul esi, 20
    add esi, item_names          ; Point to current item name

save_menu_name_loop:
    mov al, [esi]
    test al, al
    jz save_menu_add_comma       ; End of name
    mov [edi + ecx], al          ; Copy character
    inc ecx
    inc esi
    jmp save_menu_name_loop

save_menu_add_comma:
    mov byte [edi + ecx], ','    ; Add comma
    inc ecx
    mov eax, [item_prices + ebx*4]  ; Add price
    add eax, '0'
    mov [edi + ecx], al
    inc ecx
    mov byte [edi + ecx], 10     ; Add newline
    inc ecx
    inc ebx
    jmp save_menu_loop

save_menu_write:
    mov eax, 4                   ; Write buffer to file
    mov ebx, [menu_fd]
    mov edx, ecx                 ; Length of data
    mov ecx, temp_buffer
    int 0x80
    
    mov eax, 6                   ; Close file
    mov ebx, [menu_fd]
    int 0x80
    ret

parse_menu:
    ; Parse menu buffer into item_names and item_prices arrays
    mov esi, buffer
    mov edi, 0                   ; Buffer position
    mov ebx, 0                   ; Item count

parse_menu_loop:
    cmp edi, [read_bytes]
    jge parse_menu_done          ; Done if end of buffer reached
    
    push ebx
    imul ebx, 20
    lea ecx, [item_names + ebx]  ; Point to current item name slot
    pop ebx

parse_menu_name_loop:
    mov al, [esi + edi]
    cmp al, ','                  ; Look for comma
    je parse_menu_read_price
    mov [ecx], al                ; Copy name character
    inc ecx
    inc edi
    jmp parse_menu_name_loop

parse_menu_read_price:
    mov byte [ecx], 0            ; Null-terminate name
    inc edi
    movzx eax, byte [esi + edi]  ; Read price (single digit)
    sub eax, '0'
    mov [item_prices + ebx*4], eax  ; Store price

parse_menu_skip_line:
    inc edi
    cmp edi, [read_bytes]
    jge parse_menu_done
    cmp byte [esi + edi], 10     ; Skip to next line
    jne parse_menu_skip_line
    
    inc edi
    inc ebx                      ; Next item
    jmp parse_menu_loop

parse_menu_done:
    mov [item_count], ebx        ; Update item count
    ret

display_menu:
    ; Display the menu from the buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt_menu         ; Show menu header
    mov edx, prompt_menu_len
    int 0x80
    
    mov esi, buffer
    mov edi, buffer
    add edi, [read_bytes]        ; End of buffer

process_loop:
    cmp esi, edi
    jae display_menu_done        ; Done if end reached
    mov ebx, esi                 ; Start of current segment

find_comma:
    cmp byte [esi], ','          ; Look for comma
    je found_comma
    cmp byte [esi], 10           ; Look for newline
    je next_line
    cmp esi, edi
    jae display_menu_done
    inc esi
    jmp find_comma

found_comma:
    mov ecx, ebx                 ; Display item name
    mov edx, esi
    sub edx, ebx                 ; Length of name
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    mov ecx, rm_string           ; Display " RM"
    mov edx, 3
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    inc esi
    mov ebx, esi                 ; Start of price

find_newline:
    cmp byte [esi], 10           ; Look for newline
    je found_newline
    cmp esi, edi
    jae display_menu_done
    inc esi
    jmp find_newline

found_newline:
    mov ecx, ebx                 ; Display price
    mov edx, esi
    sub edx, ebx                 ; Length of price
    mov eax, 4
    mov ebx, 1
    int 0x80
    
    mov eax, 4                   ; Newline
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

next_line:
    inc esi
    jmp process_loop

display_menu_done:
    ret

find_item:
    ; Find an item in the menu by name
    mov ecx, 0                   ; Item index

find_item_loop:
    cmp ecx, [item_count]
    jge find_item_not_found      ; Not found if end reached
    
    push ecx
    mov esi, ecx
    imul esi, 20
    add esi, item_names          ; Point to item name
    mov edi, input_buf           ; Point to input

find_item_compare_loop:
    mov al, [esi]
    mov bl, [edi]
    test al, al                  ; Check end of item name
    jz find_item_check_end
    test bl, bl                  ; Check end of input
    jz find_item_next
    cmp al, bl                   ; Compare characters
    jne find_item_next
    inc esi
    inc edi
    jmp find_item_compare_loop

find_item_check_end:
    test bl, bl                  ; Ensure input ends too
    jnz find_item_next
    
    pop ecx
    mov [item_index], ecx        ; Store found index
    mov byte [item_found], 1     ; Mark as found
    ret

find_item_next:
    pop ecx
    inc ecx                      ; Next item
    jmp find_item_loop

find_item_not_found:
    ret

exit:
    ; Exit the program
    mov eax, 1                   ; Syscall: exit
    xor ebx, ebx                 ; Return code 0
    int 0x80
