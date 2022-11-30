# #############################################################
# Dynamic array
# #############################################################
# 4 Bytes - Capacity
# 4 Bytes - Size
# 4 Bytes - Address of the Elements
# #############################################################

# #############################################################
# Song
# #############################################################
# 4 Bytes - Address of the Name (name itself is 64 bytes)
# 4 Bytes - Duration
# #############################################################


.data

space: .asciiz " "
newLine: .asciiz "\n"
tab: .asciiz "\t"
menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
menuWarn: .asciiz "Please enter a valid input!\n"
name: .asciiz "Enter the name of the song: "
duration: .asciiz "Enter the duration: "
name2: .asciiz "Song name: "
duration2: .asciiz "Song duration: "
emptyList: .asciiz "List is empty!\n"
noSong: .asciiz "\nSong not found!\n"
songAdded: .asciiz "\nSong added.\n"
songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
songListAddress: .word 0                                                # the address of the song list stored here!

.text
main:

    jal     initDynamicArray
    sw      $v0,                songListAddress

    la      $t0,                sReg
    lw      $s0,                0($t0)
    lw      $s1,                4($t0)
    lw      $s2,                8($t0)
    lw      $s3,                12($t0)
    lw      $s4,                16($t0)
    lw      $s5,                20($t0)
    lw      $s6,                24($t0)
    lw      $s7,                28($t0)

menuStart:
    la      $a0,                menu
    li      $v0,                4
    syscall 

    li      $v0,                5
    syscall 
    li      $t0,                1
    beq     $v0,                $t0,                addSong
    li      $t0,                2
    beq     $v0,                $t0,                deleteSong
    li      $t0,                3
    beq     $v0,                $t0,                listSongs
    li      $t0,                4
    beq     $v0,                $t0,                terminate

    la      $a0,                menuWarn
    li      $v0,                4
    syscall 
    b       menuStart

addSong:
    jal     createSong
    lw      $a0,                songListAddress
    move    $a1,                $v0
    jal     putElement
    b       menuStart

deleteSong:
    lw      $a0,                songListAddress
    jal     findSong
    lw      $a0,                songListAddress
    move    $a1,                $v0
    jal     removeElement
    b       menuStart

listSongs:
    lw      $a0,                songListAddress
    jal     listElements
    b       menuStart

terminate:
    la      $a0,                newLine
    li      $v0,                4
    syscall 
    syscall 

    li      $v0,                1
    move    $a0,                $s0
    syscall 
    move    $a0,                $s1
    syscall 
    move    $a0,                $s2
    syscall 
    move    $a0,                $s3
    syscall 
    move    $a0,                $s4
    syscall 
    move    $a0,                $s5
    syscall 
    move    $a0,                $s6
    syscall 
    move    $a0,                $s7
    syscall 

    li      $v0,                10
    syscall 


initDynamicArray:
    subu    $sp,                $sp,                4                   # save required values to stack for not losing
    sw      $ra,                0($sp)


    li      $v0,                9                                       # allocate 12 bytes for the dynamic array
    li      $a0,                12
    syscall 


    li      $t0,                2                                       # first for bytes are for the capacity
    sw      $t0,                0($v0)

    sw      $zero,              4($v0)                                  # second four bytes are for the size which is 0

    move    $t1,                $v0


    li      $v0,                9                                       # allocate 8 bytes of memory
    li      $a0,                8                                       # initialCapacity * 4 = 8
    syscall 

    sw      $zero,              0($v0)                                  # initialize the elements to 0
    sw      $zero,              4($v0)

    sw      $v0,                8($t1)                                  # third four bytes are for the address of the elements

    move    $v0,                $t1                                     # we have address in t1, put it to return register v0

    lw      $ra,                0($sp)
    addu    $sp,                $sp,                4                   # restore stack
    jr      $ra

putElement:
                                                                        # # a0 = address of the dynamic array
                                                                        # # a1 = address of the song
    subu    $sp,                $sp,                20                  # save required values to stack for not losing
    sw      $ra,                0($sp)
    sw      $s0,                4($sp)
    sw      $s1,                8($sp)
    sw      $s2,                12($sp)
    sw      $s3,                16($sp)



    lw      $t0,                4($a0)                                  # get the size of the array
    sll     $t0,                $t0,                2                   # multiply by 4

    lw      $s1,                8($a0)                                  # get the address of the elements

goNext:                                                                 # find the first empty location (0)
    lw      $s0,                0($s1)                                  # get the address of the song
    beq     $s0,                $zero,              putS                # if the address is 0, then add the song
    addu    $s1,                $s1,                4                   # else go to the next element
    b       goNext

putS:
    sw      $a1,                0($s1)                                  # save the address of the song to the end of the array

    lw      $t0,                4($a0)                                  # get the size of the array
    addiu   $t0,                $t0,                1                   # increment size by 1
    sw      $t0,                4($a0)                                  # save the new size

    lw      $t1,                0($a0)                                  # get the capacity of the array
    beq     $t0,                $t1,                increaseCapacity    # if the size is equal to the capacity, increase the capacity
    bne     $t0,                $t1,                endPut              # if $t0 != $t1 then goto endPut

increaseCapacity:

    sll     $t1,                $t1,                1                   # multiply by 2
    sw      $t1,                0($a0)                                  # save the new capacity

    move    $t3,                $a0                                     # save the address of the dynamic array

    sll     $t4,                $t1,                2                   # multiply by 4

    li      $v0,                9
    move    $a0,                $t4                                     # allocate t1 * 4 bytes of memory
    syscall 

    move    $t2,                $v0                                     # we have new elements array in v0
    move    $s3,                $v0

    lw      $s0,                0($t3)                                  # get the capacity of the array
    lw      $t0,                4($t3)                                  # get the size of the array
    lw      $t1,                8($t3)                                  # get the address of the elements
    move    $s2,                $t3                                     # save the address of the dynamic array

    move    $a0,                $v0                                     # fill new array with zeros
    move    $a1,                $s0
    jal     fillWithZeros

    move    $a0,                $t1                                     # copy elements to the new array
    move    $a1,                $v0
    move    $a2,                $t0
    jal     copyElements

    sw      $s3,                8($s2)                                  # save the address of the new elements array

endPut:

    la      $a0,                songAdded                               # print "Song added"
    li      $v0,                4
    syscall 

    lw      $ra,                0($sp)
    lw      $s0,                4($sp)
    lw      $s1,                8($sp)
    lw      $s2,                12($sp)
    lw      $s3,                16($sp)
    addu    $sp,                $sp,                20                  # restore stack
    jr      $ra


removeElement:
                                                                        # a0 = address of the dynamic array
                                                                        # a1 = index of the element to be removed


    subu    $sp,                $sp,                16                  # save required values to stack for not losing
    sw      $ra,                0($sp)
    sw      $s1,                4($sp)
    sw      $s2,                8($sp)
    sw      $s3,                12($sp)

    addi    $t0,                $a1,                1                   # $t0 = $a1 + 1

    beq     $t0,                $zero,              endWithNoElement    # if the index + 1  = 0 (index = -1), end the function

    move    $s1,                $a0                                     # save the address of the dynamic array

    lw      $s2,                4($s1)                                  # get the size of the array
    lw      $s3,                8($s1)                                  # get the address of the elements

    li      $t1,                0                                       # counter
    li      $t2,                1                                       # flag

    beq     $s2,                $zero,              endWithNoElement    # if the size is 0, end the function

goNextElement:                                                          # find element to remove

    beq     $t1,                $a1,                startShift          # if the address of the song is equal to the address of the element to be removed, remove the element
    addu    $s3,                $s3,                4                   # go to next element
    addu    $t1,                $t1,                1                   # increment flag by 1
    j       goNextElement

startShift:                                                             # shift elements to the empty space

    beq     $s2,                $t2,                clean

    lw      $t0,                4($s3)                                  # get the address of the next
    sw      $t0,                0($s3)                                  # save the address of the next to the current

    addu    $s3,                $s3,                4                   # go to next element
    addu    $t1,                $t1,                1                   # increment counter by 1

    beq     $t1,                $s2,                clean               # if the counter is equal to the size, end the loop

    j       startShift



clean:
    lw      $t0,                4($s1)                                  # get the size of the array
    addiu   $t0,                $t0,                -1                  # decrement size by 1
    sw      $t0,                4($s1)                                  # save the new size

    lw      $t1,                0($s1)                                  # get the capacity of the array
    sra     $t1,                $t1,                1                   # divide by 2
    subu    $t1,                $t1,                -1                  # decrement the result by 1 (capacity / 2 - 1)

    bgt     $t0,                $t1,                endRemove           # if the t0 is smaller than or equal to the t1, then decrease the capacity

decreaseCapacity:

    addu    $t1,                $t1,                1                   # increment the result by 1 (capacity / 2)
    sw      $t1,                0($s1)                                  # save the new capacity


    sll     $t4,                $t1,                2                   # multiply by 4

    li      $v0,                9
    move    $a0,                $t4                                     # allocate capacity * 4 bytes of memory
    syscall                                                             # we have new elements array in v0

    lw      $t2,                0($s1)                                  # get capacity of the array
    lw      $s0,                4($s1)                                  # get the size of the array
    lw      $t1,                8($s1)                                  # get the address of the elements

    move    $a0,                $v0                                     # we have new elements array in a0
    move    $a1,                $t2                                     # we have capacity of array in a1
    jal     fillWithZeros                                               # fill new array with zeros

    move    $a0,                $t1                                     # we have address of the old elements array in a0
    move    $a1,                $v0                                     # we have the new elements array in a1
    move    $a2,                $s0                                     # we have size of array in a2
    jal     copyElements                                                # copy the elements from the old array to the new array

    sw      $v0,                8($s1)                                  # save the address of the new elements array

endRemove:
    la      $a0,                songDeleted                             # print "Song deleted"
    li      $v0,                4
    syscall 

endWithNoElement:
    lw      $ra,                0($sp)
    lw      $s1,                4($sp)
    lw      $s2,                8($sp)
    lw      $s3,                12($sp)
    addu    $sp,                $sp,                16
    jr      $ra

listElements:

    subu    $sp,                $sp,                8                   # save required values to stack for not losing
    sw      $ra,                0($sp)
    sw      $s0,                4($sp)

    lw      $t0,                4($a0)                                  # get the size of the array
    beq     $t0,                $zero,              noItem              # if size is 0, then the list is empty

    lw      $s0,                8($a0)                                  # get the address of the elements

    la      $a0,                newLine
    li      $v0,                4
    syscall 


listElementsLoop:

    beq     $t0,                $zero,              finishList          # if $t0 == $zero then goto finishList (all elements are printed)
    lw      $a0,                0($s0)

    jal     printElement

    addu    $s0,                $s0,                4                   # go to next element
    addiu   $t0,                $t0,                -1                  # decrement size by 1
    j       listElementsLoop


noItem:
    la      $a0,                emptyList                               # print "The list is empty"
    li      $v0,                4
    syscall 
finishList:
    lw      $ra,                0($sp)
    lw      $s0,                4($sp)
    addu    $sp,                $sp,                8
    jr      $ra

compareString:
                                                                        # a0 = address of the first string
                                                                        # a1 = address of the second string
                                                                        # v0 = 1 if the first string is equal to second string, 0 otherwise

    subu    $sp,                $sp,                12                  # save required values to stack for not losing
    sw      $ra,                0($sp)
    sw      $s0,                4($sp)
    sw      $s1,                8($sp)

    li      $t0,                0                                       # counter for the loop
    li      $t1,                64                                      # flag for the loop (maximum string size)

    move    $s0,                $a0                                     # save the address of the first string
    move    $s1,                $a1                                     # save the address of the second string


compareStringLoop:

    li      $v0,                0

    lb      $t2,                0($s0)                                  # get the character of the first string
    lb      $t3,                0($s1)                                  # get the character of the second string

    bne     $t2,                $t3,                endCompareString    # if the characters are not equal, end the loop
    li      $v0,                1

    addiu   $t0,                $t0,                1                   # increment the counter
    addiu   $s0,                $s0,                1                   # go to next byte of the first string
    addiu   $s1,                $s1,                1                   # go to next byte of the second string

    beq     $t1,                $t0,                endCompareString

    j       compareStringLoop

endCompareString:

    lw      $ra,                0($sp)
    lw      $s0,                4($sp)
    lw      $s1,                8($sp)
    addu    $sp,                $sp,                12

    jr      $ra

printElement:
                                                                        # song address comes in the $a0
                                                                        # save required values to stack for not losing
    subu    $sp,                $sp,                8
    sw      $ra,                0($sp)
    sw      $a0,                4($sp)

    jal     printSong

    lw      $ra,                0($sp)
    lw      $a0,                4($sp)
    addu    $sp,                $sp,                8                   # restore stack

    move    $v0,                $a0

    jr      $ra

createSong:
    subu    $sp,                $sp,                4                   # save values to stack
    sw      $ra,                0($sp)

    li      $a0,                0

    la      $a0,                name
    li      $v0,                4
    syscall 



    li      $v0,                9
    li      $a0,                64                                      # allocate 64 byte memory
    syscall 
    move    $t0,                $v0                                     # $t0 = $v0 # address  of the string name


    li      $v0,                8
    move    $a0,                $t0
    syscall 


    la      $a0,                duration
    li      $v0,                4
    syscall 

    li      $v0,                5                                       # get the duration of the song
    syscall 

    move    $t1,                $v0                                     # t1 holds the duration of the song
                                                                        # allocate 8 bytes for the song
    li      $v0,                9
    li      $a0,                8
    syscall 
                                                                        # save name of the song to the first 4 bytes of the song
    sw      $t0,                0($v0)
                                                                        # save duration of the song to the second 4 bytes of the song
    sw      $t1,                4($v0)
                                                                        # restore values from the stack
    lw      $ra,                0($sp)
    addu    $sp,                $sp,                4

    jr      $ra


findSong:
                                                                        # song list address comes in the a0
                                                                        # v0 = index of the song if found, -1 otherwise


    subu    $sp,                $sp,                16                  # save required values to stack for not losing
    sw      $ra,                0($sp)
    sw      $s0,                4($sp)
    sw      $s1,                8($sp)
    sw      $s2,                12($sp)

    move    $t5,                $a0                                     # save a0


    la      $a0,                name                                    # get song name from the user
    li      $v0,                4
    syscall 

    li      $v0,                8
    la      $a0,                copmStr
    li      $a1,                64
    move    $t0,                $a0
    syscall 

    la      $a1,                copmStr
    move    $a1,                $t0

    move    $a0,                $t5                                     # restore a0


    lw      $s0,                4($a0)                                  # get the size of the array
    beq     $s0,                $zero,              noItem              # if size is 0, then the list is empty

    li      $s1,                0                                       # counter for the loop
    lw      $s2,                8($a0)                                  # get the address of the elements

foundElementLoop:
    lw      $t4,                0($s2)                                  # get the address of the song
    lw      $a0,                0($t4)                                  # get the address of the name of the song

    jal     compareString

    bne     $v0,                $zero,              itemFound           # if $v0 = 1 then item found


    addu    $s1,                $s1,                1                   # increment the counter
    addu    $s2,                $s2,                4                   # go to next element
    slt     $t3,                $s1,                $s0                 # $t3 = ($t1 < $t0) ? 1 : 0
    bne     $t3,                $zero,              foundElementLoop

itemFound:

    beq     $v0,                $zero,              itemNotFound        # if $v0 = 0 then item not found (check after loop)

    move    $v0,                $s1                                     # $v0 = $t4, return the index of the song

    lw      $ra,                0($sp)
    lw      $s0,                4($sp)
    lw      $s1,                8($sp)
    sw      $s2,                12($sp)
    addu    $sp,                $sp,                16
    jr      $ra

itemNotFound:

    la      $a0,                noSong
    li      $v0,                4
    syscall 

    li      $v0,                -1                                      # return 0

    lw      $ra,                0($sp)
    lw      $s0,                4($sp)
    lw      $s1,                8($sp)
    sw      $s2,                12($sp)
    addu    $sp,                $sp,                16
    jr      $ra

printSong:
                                                                        # save required values to stack for not losing
    subu    $sp,                $sp,                8
    sw      $ra,                0($sp)
    sw      $a0,                4($sp)

    move    $t3,                $a0                                     # $t3 = $a0

    lw      $t4,                0($t3)                                  # get the address of the name

    la      $a0,                name2
    li      $v0,                4
    syscall 

    la      $a0,                0($t4)
    li      $v0,                4
    syscall 




    lw      $t4,                4($t3)                                  # get the address of the duration
    la      $a0,                duration2
    li      $v0,                4
    syscall 

    la      $a0,                0($t4)
    li      $v0,                1
    syscall 

    la      $a0,                newLine
    li      $v0,                4
    syscall 

    la      $a0,                newLine
    li      $v0,                4
    syscall 


    lw      $ra,                0($sp)
    lw      $a0,                4($sp)
    addu    $sp,                $sp,                8                   # restore stack

    jr      $ra

additionalSubroutines:

fillWithZeros:
                                                                        # a0 = address of the array
                                                                        # a1 = size of the array
    subu    $sp,                $sp,                4
    sw      $ra,                0($sp)


zeroLoop:
    beq     $a1,                $zero,              zeroLoopEnd         # if $a1 == 0 goto zeroLoopEnd

    sw      $zero,              0($a0)                                  # fill the array with zeros

    addu    $a0,                $a0,                4                   # increment the address of the array
    addu    $a1,                $a1,                -1                  # decrement the size of the array
    b       zeroLoop

zeroLoopEnd:


    lw      $ra,                0($sp)
    addu    $sp,                $sp,                4                   # restore stack

    jr      $ra


copyElements:
                                                                        # a0 = address of the source array
                                                                        # a1 = address of the destination array
                                                                        # a2 = size of the array
    subu    $sp,                $sp,                4
    sw      $ra,                0($sp)

copyLoop:
    beq     $a2,                $zero,              copyLoopEnd         # if $a2 == 0 goto copyLoopEnd

    lw      $t0,                0($a0)                                  # get the element of the source array
    sw      $t0,                0($a1)                                  # copy the element to the destination array

    addu    $a0,                $a0,                4                   # go to next in soruce
    addu    $a1,                $a1,                4                   # go to next in destination
    addu    $a2,                $a2,                -1                  # decrement the size
    b       copyLoop

copyLoopEnd:
    lw      $ra,                0($sp)
    addu    $sp,                $sp,                4                   # restore stack

    jr      $ra

