TITLE Project 6 - Portfolio Project     (Proj6_mccuenr.asm)

; Author: Russ McCuen
; Last Modified: 12/05/2021
; OSU email address: mccuenr@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:    6            Due Date: 12/05/2021
; Description: Implements and tests two macros for string processing:
;			   mGetString - displays prompt & gets user's input into memory location
;              mDisplayString - prints the string which is stored in specified memory location
;			   Implements and tests two procedures for signed integers which use string primitive instructions:
;              ReadVal - invokes mGetString, converts string of ASCII to numeric value (SDWORD), validates user entry
;			   WriteVal - covnerts numeric SDWORD to string of ASCII to string of ASCII digits, invokes mDisplayString
;			   Gets 10 valid integers from user, stores ints in array, displays ints, their sum, and truncated average


INCLUDE Irvine32.inc

USER_NUMBERS = 10										; constant - user should enter 10 numbers

;-----------------------------------------------------------------------------------------------
; Macro name: mGetString
;
; Prompts user to enter 10 signed decimal integers that must fit inside a 32-bit register
;
; Receives:
; promptUser = ask for number
; inputString = array address
; inputLength = array length
;
; Returns: string input by user and length of string input by user
;----------------------------------------------------------------------------------------------
mGetString		MACRO	promptUser, inputString, inputLength
  push		edx
  push		ecx

  mov		edx, promptUser
  call		WriteString
  mov		ecx, 15										; I set the input string to max length of 15
  mov		edx, inputString
  call		ReadString
  mov		inputLength, eax			

  pop		ecx
  pop		edx
	
ENDM

;----------------------------------------------------------------------------------------------------
; Macro name: mDisplayString
;
; Prints the string which is stored in a specified memory location
;
; Receives: address of string to display
;
; returns:	None (but displays the output string to the console)
;-----------------------------------------------------------------------------------------------------
mDisplayString	MACRO	stringAddress
  push		edx		
	
  mov		edx, stringAddress
  call		WriteString

  pop		edx								
ENDM

.data

intro				BYTE		"Final 271 Project (OMG SO HAPPY!): Designing low-level I/O procedures, by Russ McCuen", 13, 10, 0
intro2				BYTE		13, 10, "Please input 10 signed decimal integers.", 13, 10, 0
intro3				BYTE		"Each integer needs to be small enough to fit inside a 32-bit register.", 13, 10, 0
intro4				BYTE		"After you have input 10 integers, a list of those integers, their sum, ", 13, 10, 0
intro5				BYTE		"and their average value will be displayed.", 13, 10, 0
userPrompt			BYTE		"Please enter a signed integer: " ,0
userEntry			BYTE		15 Dup(?)				; I think 13 would be fine but did 15 jsut in case			
userError			BYTE		"DANGER!!! INVALID ENTRY! Please try again.", 13,10,0
userNums			BYTE		"You entered the following numbers: ", 13, 10, 0
comma				BYTE		", ", 0
asciiString			BYTE		15 Dup(?)				; although I don't think it matters because > 12 would be cut off		 
validNums			SDWORD		USER_NUMBERS Dup(?)		
userNumSum			BYTE		13, 10, "The sum of your numbers is: ", 0
userSum				SDWORD		?
userNumAvg			BYTE		13, 10, "The truncated average of your numbers is: ", 0
userAvg				SDWORD		?
stringLength		DWORD		?						
validNum			SDWORD		?
numberCount			DWORD		0						
negativeNum			DWORD		0
doneWith271			BYTE		"All projects for CS 271 are now complete! Thanks for taking part!", 13,10,0

.code

main PROC

  push			OFFSET intro
  push			OFFSET intro2
  push			OFFSET intro3
  push			OFFSET intro4
  push			OFFSET intro5
  call			introduction
	
  mov			edi, OFFSET validNums					; where we store valid user entries				
  mov			ecx, USER_NUMBERS						; number of valid user entries we need
	
  ; user input loop must be in main (not paying attention to this meant I had to write this twice!)  
  getInput:
	  push			USER_NUMBERS						; need 10 numbers
	  push			numberCount							; how many numbers?
	  push			stringLength						; length of each entry
	  push			negativeNum							; to ensure negative numbers are printed as negative numbers
	  push			OFFSET userPrompt					; prompt user to enter number
	  push			OFFSET userEntry					; user entered string
	  push			OFFSET userError					; try again	
	  push			OFFSET validNum						; actual number (not string)			
	  push			OFFSET asciiString					; ascii interpretation of string	
	  call			ReadVal
	  mov			eax, validNum
	  stosd												; store string data
	  loop			getInput							; loop that is IN MAIN!!!!!
  
  call			CrLf
	
  mov			ecx, USER_NUMBERS					
  mov			esi, OFFSET validNums		
  
  mDisplayString OFFSET userNums

  printNums:
	  push			USER_NUMBERS						; user enters 10 numbers
	  push			[esi]											
	  push			OFFSET asciiString					; ascii string to be printed
	  call			WriteVal							; print ascii string currently pointed to
	  cmp			ecx, 1								; what is the counter at? (for commas)
	  jz			getSum								; no more commas
	  mDisplayString OFFSET comma						; still need a comma			
	  add			esi, 4								; go to the next ascii string to print
	  loop			printNums							; keep printing!
  
 getSum:
  mov			eax, 0
  mov			esi, OFFSET validNums					; valid numbers entered by user
  mov			ecx, USER_NUMBERS						; user entered 10 numbers

  calculateSum:
	  add			eax, [esi]							; add value to sum
	  add			esi, 4								; go to next value
	  loop			calculateSum						; keep adding until all numbers iterated through
  
  mov			userSum, eax							; place sum value in userSum

  mDisplayString OFFSET userNumSum						; print message of number sum

  push			USER_NUMBERS
  push			userSum
  push			OFFSET asciiString
  call			WriteVal								; print sum of user entered numbers

  mov			ebx, USER_NUMBERS						; 10 numbers entered so divide by this for average
  mov			eax, userSum							; sum of user numbers entered, divide by USER_NUMBERS to get average
  cdq													; sign extend to ensure correct result obtained
  idiv			ebx										; divide by 10 to get average
  mov			userAvg, eax							; calculated truncated average
  
  mDisplayString OFFSET userNumAvg						; print message of user numbers truncated average
	
  push			USER_NUMBERS
  push			userAvg									; truncated average of user numbers entered
  push			OFFSET asciiString						; ascii string to print (for user nums entered)
  call			WriteVal								; WRITE IT!
  call			CrLf									; for pretty
  call			CrLf

  push			OFFSET doneWith271						; final 271 goodbye message!!!!!
  call			byeBye271								; I know we still have the final . . . but PROJECTS ARE DONE!!!
  call			CrLf

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --introduction--
; Prints introduction and instructions using mDisplayString
; preconditions: intro and inst1-4 are strings that introduce the program and contain instructions
; postconditions: intro and instructions printed to screen
; receives: intro and instructions 1-4
; returns: intro and instructions printed to screen

introduction PROC
  push				ebp
  mov				ebp, esp				
	
  mDisplayString	[ebp + 24]							; print intro
  mDisplayString 	[ebp + 20]							; print instructions 1 - 4
  mDisplayString	[ebp + 16]
  mDisplayString	[ebp + 12]
  mDisplayString	[ebp + 8]
  call				CrLf

  pop				ebp
  ret				20      

introduction ENDP

; --ReadVal--
; Uses mGetString macro to get user input in the form of a string of digits.
; Converts string of ASCII digits to numbers, validating input as it goes.
; Stores each value in a memory variable, by reference.
; preconditions: userEntry, userPrompt, userError, and asciiString are all strings that have been created.
;                numCount, negativeNum, and stringLength are variables that have been created.
;				 USER_NUMS has been created as a constant; validNums is an array that has been created.
; postconditions: none
; receives: USER_NUMS, stringLength, userEntry, userPrompt, validNums, numberCount, userError, negativeNum, and asciiString
; returns: array of numbers that have been validated

ReadVal PROC
  push			ebp
  mov			ebp, esp				
  pushad												

promptUser:
  mGetString	[ebp + 24], [ebp + 20], [ebp + 32]		; MACRO call for prompt, enteredString, and stringLength
  mov			ecx, [ebp + 32]							; counter = stringLength
  mov			esi, [ebp + 20]							; source = entered string	
  mov			edi, [ebp + 12]							; valid number				
  cld											

  checkIsValid:
      lodsb
      cmp			ecx, 12								; max length is 11 if there is a sign, so > 11 = invalid
      jae			notValid					
      mov			ebx, [ebp + 32]
      cmp			ebx, ecx							; if stringLength is 11, is first char + or - ?
      jne			keepChecking					
      cmp			al, 43								; 43 = ASCII value for +
      jz			getNext
      cmp			al, 45								; 45 = ASCII value for -
      jz			isNegative							; treat as negative number
      jmp			keepChecking

  isNegative:
      mov			ebx, 1
      mov			[ebp + 28], ebx						; sets isNegative to 1
      jmp			getNext								; ready for next character

  keepChecking:
      cmp			al, 57								; 57 = ASCII value for 9
      jg			notValid							; if > 57, not valid
      cmp			al, 48								; 48 = ASCII value for 0
      jl			notValid							; if < 0, not valid
      sub			al, 48								; convert ASCII to number
      movsx			eax, al								
      push			eax
      mov			ebx, 10
      mov			eax, [ebp + 36]						; counts numbers converted
      imul			ebx
      pop			ebx
      jo			notValid							; if overflow, then error
      add			eax, ebx
      mov			[ebp + 36], eax						
      jo			notValid							; if overflow, then error

  getNext:
      loop			checkIsValid						; keep checking

  mov				ebx, 1
  cmp				[ebp + 28], ebx						; is it negative?
  jne				isValid
  neg				eax									; if so, negate

isValid:
  mov				[edi], eax							; if valid, store number
  jmp				theEnd
	
notValid:
	mDisplayString	[ebp + 16]							; ERROR! ERROR!
	mov				ebx, 0						
	mov				[ebp + 36], ebx						; integer conversion count reset for further checks
	mov				[ebp + 28], ebx						; isNegative reset for further checks
	jmp				promptUser

theEnd:
  popad												
  pop				ebp
  ret				36

ReadVal	ENDP

; --WriteVal--
; Converts numeric value into string of ASCII digits, then prints ASCII string using mDisplayString
; preconditions: USER_NUMS declared as constant, nums converted to ASCII, asciiString delcared as string
; postconditions: none
; receives: USER_NUMS, number to be converted, address of asciiString
; returns: asciiString to print (printed to display)

WriteVal PROC
	push			ebp
	mov				ebp, esp				
	pushad												

	mov				ecx, 0								; counter
	mov				edi, [ebp + 8]						; asciiString regardless of call					
	mov				esi, [ebp + 12]						; either userSum or userNumAvg							
	mov				eax, esi
	cmp				eax, 0							
	jge				getASCII
	push			eax									
	mov				al, 45								; add '-' to the string for neg nums
	stosb												; store string data
	pop				eax
	neg				eax									; makes positive because will be adding - if negative later

  getASCII:
	  mov			ebx, [ebp + 16]						; get ready to divide				
	  cdq												; sign extend for correct answer
	  idiv			ebx									; divide by USER_NUMS
	  add			edx, 48								; add ASCII value for 0 to get ASCII equivalent number (remainder + ASCII 0)
	  push			edx									; remainder goes to stack
	  inc			ecx									; increment counter						
	  cmp			eax, 0								; are we done?
	  jz			getReverse							; if yes, get ready to print
	  jmp			getASCII							; if not, get next ASCII

  getReverse:
	  pop			eax									
	  stosb												; store string data
	  loop			getReverse							; keep reversing until full string complete

  mov				al, 0								; 0 = null terminator, so string is done!
  stosb													; store string data
  mDisplayString [ebp + 8]								; asciiString finally ready for printing

  popad												
  pop				ebp
  ret				12

WriteVal ENDP

; --byeBye271--
; Prints the final goodbye message of the final project of 271!!!!!
; preconditions: doneWith271 is a string that is totally ready for the end of this class
; postconditions: said goodbye to the class (at least the projects)
; receives: doneWith271 string
; returns: NONE (but says hasta la vista! via display!)

byeBye271 PROC 
	push			ebp
	mov				ebp, esp				

	mDisplayString 	[ebp + 8]							;buh bye MASM

	pop				ebp						
	ret				4									; did I mention I'm happy?  

byeBye271 ENDP

END main