.data
unorderedList: .word 13, 26, 44, 99, 16, 37, 23, 67, 90, 87, 29, 41, 14, 74, 39, -1
# unorderedList: .word 13, 26,-1

insertValues: .word 46, 85, 24, 25, 3, 33, 45, 52, 62, 17

space: .asciiz " "
newLine: .asciiz "\n"

####################################
#   4 Bytes - Value
#   4 Bytes - Address of Left Node
#   4 Bytes - Address of Right Node
#   4 Bytes - Address of Root Node
####################################

.text 

main:
    la $a0, unorderedList

    jal build
    move $s3, $v0

    move $a0, $s3
    jal print

    li $s0, 8
    li $s2, 0

    la $s1, insertValues

insertLoopMain: 
    beq $s2, $s0, insertLoopMainDone

    lw $a0, ($s1)
    move $a1, $s3
    jal insert

    addi $s1, $s1, 4
    addi $s2, $s2, 1 
    b insertLoopMain
    insertLoopMainDone:

        move $a0, $s3
        jal print


        move $a0, $s3
        jal remove


        move $a0, $s3
        jal print


        li $v0, 10
        syscall 


########################################################################
# Write your code after this line
########################################################################


####################################
# Build Procedure
####################################
build:
    subu $sp, $sp, 16  # save required values to stack for not losing
    sw $a0, 0($sp)
    sw $ra, 4($sp)
    sw $s0, 8($sp)
    sw $a1, 12($sp)

    move $s0, $a0

    li $v0, 9
    li $a0, 16
    syscall 

    lw $a0, 0($sp)
 
    lw $t0, 0($a0)
    sw $t0, 0($v0)
    sw $zero, 4($v0)
    sw $zero, 8($v0)
    sw $zero, 12($v0)

    li $s4, 1   # s4 register holds the total number of elements

    insertion:  # calls insert procedure for all elements until -1
        li $t1, -1
        add $s0, $s0, 4
        lw $t0, 0($s0)
        beq $t0, $t1, buildDone

        move $a0, $t0
        jal insert



        b insertion

    buildDone:
        lw $a0, 0($sp)
        lw $ra, 4($sp)
        lw $s0, 8($sp)
        lw $a1, 12($sp)
        addu $sp, $sp, 16

        move $v0, $a0

        jr $ra

####################################
# Insert Procedure
####################################
insert:

    # a0 => new element
    # a1 => root node

    subu $sp, $sp, 16
    sw $a0, 0($sp)
    sw $ra, 4($sp)
    sw $a1, 8($sp)
    sw $s0, 12($sp)

    # memory allocation

    li $v0, 9
    li $a0, 16
    syscall 

    lw $a0, 0($sp)


    sw $a0, 0($v0)
    sw $zero, 4($v0)
    sw $zero, 8($v0)
    sw $zero, 12($v0)

    # take new node adress to s5 for not using v0
    move $s5, $v0


    move $a0, $s4
    jal createPathForIndex 

    move $s6, $v0 # s6 holds the path to the node

    li $t9, 1
    li $t8, 2

    move $s0, $a1

    goToInsertPlace: # goes to the place where the new node should be inserted using the created path
        beq $s7, $t9, insertPlaceFound

        sub $s6, $s6, 4
        sub $s7, $s7, 1
        lw $t0, 0($s6)

        beq $t0, $zero, continueToLeft # goes to left if new path way is 0
        beq $t0, $t9, continueToRight   # goes to right if new path way is 1

        j goToInsertPlace

        continueToLeft:
            add $s0, $s0, 4

            # lw $a1, 4($a1)
            j goToInsertPlace
        continueToRight:
            add $s0, $s0, 8

            # lw $a1, 8($a1)
            j goToInsertPlace
    
    insertPlaceFound:
        sub $s6, $s6, 4
        beq $s6, $zero, insertLeft
        beq $s6, $t9, insertRight      

    insertLeft: 
        sw $a1, 12($s5)
        sw $s5, 4($s0)
        j pushValue

    insertRight:
        sw $a1, 12($s5)
        sw $s5, 8($s0)
        j pushValue

    pushValue: # pushes new value to up until it is smaller than the parent (not working correctly)
        lw $t0, 0($s5) # value current node
        # lw $t1, 12($s5) # parent node adress
        beq $t1, $zero, finishPush

        lw $t2, 0($s0) # parent value
        
        
        blt $t0, $t2, finishPush
        beq $t0, $t2, finishPush

        sw $t0, 0($s0)
        sw $t2, 0($s5)
        
        # lw $s5, 12($s5)
        j pushValue

    finishPush: # increments total element count and retrieves saved values
        add $s4, $s4, 1
        move $t7, $s4
        add $t7, $t7, 1
        lw $a0, 0($sp)
        lw $ra, 4($sp)
        lw $a1, 8($sp)
        lw $s0, 12($sp)
        addu $sp, $sp, 16
        jr $ra

####################################
# Remove Procedure
####################################
remove:
    jr $ra

####################################
# Print Procedure
####################################
print:

    # a0 => root node

    subu $sp, $sp, 20
    sw $a0, 0($sp)
    sw $ra, 4($sp)
    sw $a1, 8($sp)
    sw $s0, 12($sp)
    sw $s4, 16($sp)

    li $s4, 1

    lw $a0, 0($a0)

  
    printNode:
        move $a0, $s4
        jal createPathForIndex

        lw $a0, 0($sp)
        move $s0, $a0

        move $s6, $v0

        li $t9, 1
        li $t8, 2

        goToPrintNode: # goes to the place where the current node to be printed exists using created path
            beq $s7, $zero, printNodeFound

            sub $s6, $s6, 4
            sub $s7, $s7, 1
            lw $t0, 0($s6)

            beq $t0, $zero, goLeft
            beq $t0, $t9, goRight

            j goToPrintNode

            goLeft:
                add $s0, $s0, 4

                # lw $a1, 4($a1)
                j goToPrintNode
            goRight:
                add $s0, $s0, 8

                # lw $a1, 8($a1)
                j goToPrintNode
        
        printNodeFound:
            lw $t0, 0($s0)
            
            move $a0, $t0
            li $v0, 1
            syscall

            la $a0, space
            li $v0, 4
            syscall

            add $s4, $s4, 1
            beq $t7, $s4, finishPrint
            j printNode
            # sub $s6, $s6, 4
            # beq $s6, $zero, printLeft
            # beq $s6, $t9, printRight      

        printLeft:
            sw $a1, 12($s5)
            sw $s5, 4($s0)
            j printNode

        printRight:
            sw $a1, 12($s5)
            sw $s5, 8($s0)
            j printNode

    finishPrint:


        la $a0, newLine
        li $v0, 4
        syscall

        lw $a0, 0($sp)
        lw $ra, 4($sp)
        lw $a1, 8($sp)
        lw $s0, 12($sp)
        lw $s4, 16($sp)
        addu $sp, $sp, 20

        jr $ra


####################################
# Extra Procedures
####################################
extraProcedures:

    # a0 => current index (number of total elements)
    createPathForIndex: # creates path for new node to be inserted (0 => left 1 => right) [0,1,0] => [left,right,left]
        subu $sp, $sp, 12
        sw $a0, 0($sp)
        sw $ra, 4($sp)
        sw $s4, 8($sp)

        move $s4, $a0
        move $t0, $s4

        li $s7, 1

        incrementPathLength: # finds the length of the path according to the index
            srl $t0, $t0, 1
            beq $zero, $t0, pathLengthFound
            add $s7, $s7, 1
            j incrementPathLength
        pathLengthFound:

        sll $s7, $s7, 2

        li $v0, 9
        move $a0, $s7
        syscall 

        srl $s7, $s7, 2

        lw $s4, 0($sp)

        move $t0, $s4

        setNewPath:
        
            beq $t0, $zero, setPathDone

            li $t1, 1

            and $t2, $t0, $t1

            beq $t2, $t1, evenIndex
            beq $t2, $zero, oddIndex

            evenIndex: # adds 1 to path if the index is even
                sw $zero, 0($v0)
                srl $t0, $t0, 1
                add $v0, $v0, 4
                j setNewPath

            oddIndex: # adds 0 to path if the index is odd
                sw $t1, 0($v0)
                srl $t0, $t0, 1
                add $v0, $v0, 4
                j setNewPath
        
        setPathDone:
            lw $s4, 8($sp)
            lw $ra, 4($sp)
            lw $a0, 0($sp)
            addu $sp, $sp, 12
            jr $ra
        
