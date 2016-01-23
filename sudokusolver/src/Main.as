package 
{
	//All imports required to run the program
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	/**
	 * @author Mark Bouwman
	 * App name: SudokuSolver.swf
	 * 
	 * Info: The sudoku solver picks any given sudoku field and iterates through it to see 
	 * if there is a possible solution. If there is no possible solution, the sudoku solver
	 * will crash. If there is a possible solution, the sudoku solver will find it by picking
	 * the square with the MRV every iteration and removing its first available value in the
	 * current domain. The program then makes a 'memento' of the sudokuboard, before continueing the algorithm
	 * by actually updating the square. If the forwardchecking returns that the newly set value is legal,
	 * arc consistancy kicks in to check whether or not any value of all domains can be removed. After this check,
	 * another 'memento' gets created. This way the algorithm continues the path with the updated square. If the forwardchecking
	 * returns that the state is illegal, the algorithm backtracks (seeing as there is no updated memento
	 * pushed to the stack, the top of the stack contains the memento of the sudokuboard where the MRV Square's
	 * domain got updated).
	 */
	 
	 [SWF(frameRate=60)]
	public class Main extends Sprite
	{
		private var inputLocation:String;
		private var inputField:TextField;
		private var explenation:TextField;
		
		private var iterations:int = 0;
		private var maxStackSize:int = 0;
		private var numBackTracks:int = 0;
		private var numRemovedThroughAC:int = 0;
		private var startTime:Number = 0;
		
		private var iterationsTextField:TextField = new TextField();
		private var maxStackTextField:TextField = new TextField();
		private var numBackTracksTextField:TextField = new TextField();
		private var numRemovedThroughACField:TextField = new TextField();
		private var elapsedTimeField:TextField = new TextField();
		
		/*
		 * Waits for the program to be added to the stage.
		 */
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		/*
		 * Initialises the sudoku.
		 * @param event The event called when the program is added to the stage.
		 */
		private function init(event:Event = null):void 
		{
			//Catch all errors, used for handling the user's textinput.
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleGlobalErrors);
			
			//The input field for the user.
			inputField = new TextField();
			inputField.border = true;
			inputField.width = 450;
			inputField.height = 20;
			inputField.x = 70;
			inputField.y = 120;
			inputField.text = "Keep empty for a random board created with forwardchecking.";
			inputField.type = "input";
			inputField.multiline = false;
	
			//The explenatory text.
			explenation = new TextField();
			explenation.text = "State a filename's location. The filename's location is relative to where the .SWF is located.";
			explenation.width = 455;
			explenation.height = 20;
			explenation.x = 68;
			explenation.y = 100;
			explenation.selectable = false;
			
			//Add both fields to the stage.
			addChild(inputField);
			addChild(explenation);
			
			//Set the stage's focus to the inputfield so that the user can type immediately.
			stage.focus = inputField;
			
			addEventListener(KeyboardEvent.KEY_DOWN, handleEnter);
		}
		
		/*
		 * Loads the sudoku when the user presses the ENTER key.
		 * @param event The event listener.
		 */
		private function handleEnter(event:KeyboardEvent):void
		{
			//Check if the user pressed enter.
			if(event.charCode == 13)
		   	{
				loadSudoku();
		   	}
		}
				
		/*
		 * Tries loading the input file.
		 */
		private function loadSudoku():void
		{
			inputLocation = inputField.text;
			
			if(inputLocation == "" || inputLocation == "Keep empty for a random board created with forwardchecking.")
			{
				//Generate a random sudoku board.
				var randomSudoku:Sudoku = new Sudoku();
				randomSudoku.createEmpty();
				generateRandom(randomSudoku);
				
				//Start the algorithm.
				addEventListener(Event.ENTER_FRAME, function(event:Event):void{solveSudoku(event, randomSudoku);});
			}
			else
			{
				//Add a .txt at the end if it's not in there. 
				if(inputLocation.search(".txt") != 0)
					inputLocation += ".txt";
				
				//Load the given input file.
				var textLoader:URLLoader = new URLLoader();
				textLoader.addEventListener(Event.COMPLETE, onLoadInputFile);
				textLoader.load(new URLRequest(inputLocation));
			}
		}
		
		/*
		 * Loads the sudoku from the input file.
		 * @param event The event fired by URLRequest.
		 */
		private function onLoadInputFile(event:Event):void
		{	
			//Initialise the sudoku to the given .txt's data. Do a 'forwardcheck' on each
			//non-zero value to update the initial domain for each square.
			var sudoku:Sudoku = new Sudoku(event.target.data);
			var variables:Array = sudoku.getVariables();
			for(var i:int = 0; i < variables.length; i++)
			{
				var sq:Square = variables[i];
				if(sq.getValue() != 0)
					forwardCheck(sudoku, i, sq.getValue());
			}
			
			//Start the algorithm.
			addEventListener(Event.ENTER_FRAME, function(event:Event):void{solveSudoku(event, sudoku);});
		}
		
		/*
		 * Sets all textfields to their initial state when the sudoku shows.
		 */
		private function initialiseTextFields():void
		{
			//Remove the textfields and their keyboardevents.
			removeEventListener(KeyboardEvent.KEY_DOWN, handleEnter);
			removeChild(inputField);
			removeChild(explenation);
			inputField = null;
			explenation = null;
			
			//Show tracking data.
			iterationsTextField.x = 63;
			iterationsTextField.y = -50;
			iterationsTextField.width = 200;
			iterationsTextField.text = "Amount of iterations: " + iterations.toString();
			iterationsTextField.selectable = false;
			
			maxStackTextField.x = 213;
			maxStackTextField.y = -50;
			maxStackTextField.width = 200;
			maxStackTextField.text = "Maximum stack size: " + maxStackSize.toString();
			maxStackTextField.selectable = false;
			
			numBackTracksTextField.x = 363;
			numBackTracksTextField.y = -50;
			numBackTracksTextField.width = 200;
			numBackTracksTextField.text = "Amount of backtracks: " + numBackTracks.toString();
			numBackTracksTextField.selectable = false;
			
			numRemovedThroughACField.x = 63;
			numRemovedThroughACField.y = -30;
			numRemovedThroughACField.width = 400;
			numRemovedThroughACField.text = "Amount of items removed through AC3: " + numRemovedThroughAC.toString();
			numRemovedThroughACField.selectable = false;
			
			elapsedTimeField.x = 363;
			elapsedTimeField.y = -30;
			elapsedTimeField.width = 200;
			elapsedTimeField.text = "Elapsed time: " + 0;
			elapsedTimeField.selectable = false;
			
			addChild(iterationsTextField);
			addChild(maxStackTextField);
			addChild(numBackTracksTextField);
			addChild(numRemovedThroughACField);
			addChild(elapsedTimeField);
		}
		
		private var previousState:Sudoku;
		private var stack:Array;
		private var frame:int = 0;
		private var solutionFound:Boolean = false;
		
		/*
		 * The algorithm to solve the sudoku.
		 * @param initialState The sudoku state that originates from the textfile.
		 */
		private function solveSudoku(event:Event, initialState:Sudoku):void
		{				
			//Initialise the algorithm if the previousState is null.
			if(previousState == null)
			{
				initialiseTextFields();
				startTime = getTimer();
				stack = new Array();
				stack.push(initialState);
			}
			else
			{
				//Slow down the updates so that we can actually track what's happening.
				//1 and 5 are good values: 1 is fast and 5 allows you to follow the algorithm easier.
				//frame++;
				//if(frame % 1 != 0)
				//{
				//	return;	
				//}
			}
			
			//Iterate through all mementos while the solution hasn't been found.
			if(stack.length > 0)
			{	
				//Keep track of the iterations and max stacksize.
				this.iterations++;
				if(stack.length > this.maxStackSize)
					maxStackSize = stack.length;
					
				//Get the most top state from the stack.
				var currentState:Sudoku = stack.pop();
				var mrvSquare:Square = null;
				var variables:Array = currentState.getVariables();
				
				//Refresh the display (to show backtracking).
				refreshDisplay(currentState);
				
				//Update the tracking data.
				iterationsTextField.text = "Amount of iterations: " + iterations.toString();
				maxStackTextField.text = "Maximum stack size: " + maxStackSize.toString();
				numBackTracksTextField.text = "Amount of backtracks: " + numBackTracks.toString();
				numRemovedThroughACField.text = "Amount of items removed through AC3: " + numRemovedThroughAC.toString();
				var elapsed:Number = (getTimer() - startTime) / 1000;
				elapsedTimeField.text = "Elapsed time: " + elapsed.toString() + " seconds";
			
				var checkedLocation:int = 0;
				
				//Get the square with the Minimum Remaining Value.
				for(var i:int = 0; i < variables.length; i++)
				{
					var checkedSquare:Square = variables[i];
					
					//Don't pick the square if it's locked or already set.
					if(checkedSquare.isLocked() || checkedSquare.isSet())
						continue;
						
					//Obviously something failed during the creation of this state,
					//so backtrack.
					if(checkedSquare.getDomainSize() == 0)
					{
						this.numBackTracks++;
						return;
					}
					
					//Update the MRV square if it's null or if the checked square has a 
					//smaller domainsize.
					if(mrvSquare == null)
					{
						mrvSquare = checkedSquare;
						checkedLocation = i;
					}
					else if(checkedSquare.getDomainSize() < mrvSquare.getDomainSize())
					{
						mrvSquare = checkedSquare;
						checkedLocation = i;
					}
				}
				
				//If there is no square left, it means there is no solution to the sudoku (and so we backtrack).
				if(mrvSquare == null)
				{
					this.numBackTracks++;
					return;
				}
				
				//Get the first value in the open domain, and set the square's domain accordingly.
				var newValue:int = mrvSquare.getDomain()[0];
				mrvSquare.removeFromDomain(newValue);
				
				//Create a memento of the current state before changing it and push it to the stack for later use.
				var oldState:Sudoku = new Sudoku();
				Sudoku.Copy(oldState, currentState);
				stack.push(oldState);
				
				//Set the square's new value.
				mrvSquare.setValue(newValue);
				
				//Display the currently checked square.
				mrvSquare.setCurrentlyChecked(true);
				
				//Check if we reached the end yet or not.
				if(currentState.isLegalSudoku())
				{
					//Remove everything from the stack to stop the algorithm.
					stack = new Array();
					mrvSquare.setCurrentlyChecked(false);
					solutionFound = true;
				}
				
				//Do a forwardcheck on the state, changing the domains of all influenced squares. 
				//If it's still a possible state to continue the algorithm with, push it to the stack.
				if(forwardCheck(currentState, checkedLocation, newValue))
				{
					//Check all of the domains using AC3.
					arcConsitancyCheck(currentState);
					
					//Create a memento of the current state before continueing changing it and push it to the stack for later use.
					var newState:Sudoku = new Sudoku();
					Sudoku.Copy(newState, currentState);
					stack.push(newState);
				}
				else
				{
					//Forwardchecking failed for this state, so we have to backtrack to the previous state.
					this.numBackTracks++;
				}
				
				//Refresh the display (to show which field got checked).
				refreshDisplay(currentState);
			}
			else if(solutionFound == false)
			{
				//Appereantly, there is no valid sudoku.
				iterationsTextField.text = "";
				numBackTracksTextField.text = "";
				maxStackTextField.text = "There is no solution to this sudoku!";
				numRemovedThroughACField.text = "";
				
				//Refresh the display.
				refreshDisplay(initialState);
			}
		}
		
		/*
		 * Forwardchecks to see if a state is still legal.
		 * @param sudokuState The sudoku state that the algorithm is currently in.
		 * @return Returns whether or not the state is still legal after forwardchecking. 
		 */
		private function forwardCheck(sudokuState:Sudoku, checkedLocation:int, changedValue:int):Boolean
		{						
			var row:int = Math.floor(checkedLocation / 9);
			var column:int = checkedLocation % 9;
			var variables:Array = sudokuState.getVariables();
			
			//Update the domain for each square in the same row.
			for(var i:int = 0; i < 9; i++)
			{
				//Skip if it's the same square.
				if((row * 9 + i) == checkedLocation)
					continue;
					
				var sqX:Square = variables[(row * 9 + i)];
				
				//Update the square's domain if it's a square that hasn't been set or locked.
				if(sqX.isLocked() == false && sqX.isSet() == false)
				{
					sqX.removeFromDomain(changedValue);
					
					//If the square's domainSize is 0, it means the new state is invalid.
					if(sqX.getDomainSize() == 0)
						return false;
				}
			}
			
			//Update the domain for each square in the same column.
			for(var j:int = 0; j < 9; j++)
			{
				//Skip if it's the same square.
				if((j * 9 + column) == checkedLocation)
					continue;
					
				var sqY:Square = variables[(j * 9 + column)];
				
				//Update the square's domain if it's a square that hasn't been set or locked.
				if(sqY.isLocked() == false && sqY.isSet() == false)
				{
					sqY.removeFromDomain(changedValue);
					
					//If the square's domainSize is 0, it means the new state is invalid.
					if(sqY.getDomainSize() == 0)
						return false;
				}
			}
			
			var gridX:int = Math.floor(column / 3) * 3;
			var gridY:int = Math.floor(row / 3) * 3;
			
			//Update the domain for each square in the same grid.
			for(var x:int = gridX; x < gridX + 3; x++)
			{
				for(var y:int = gridY; y < gridY + 3; y++)
				{
					//Skip if it's the same square.
					if((y * 9 + x) == checkedLocation)
						continue;
						
					var sqGrid:Square = variables[(y * 9 + x)];
					if(sqGrid.isLocked() == false && sqGrid.isSet() == false)
					{
						//Update the square's domain if it's a square that hasn't been set or locked.
						sqGrid.removeFromDomain(changedValue);
						
						//If the square's domainSize is 0, it means the new state is invalid.
						if(sqGrid.getDomainSize() == 0)
							return false;
					}
				}
			}
			
			//The state is legal.
			return true;
		}
				
		/*
		 * Checks all of the variables to see if they have any removable items from their domain.
		 * @param sudokuState The sudoku state that the algorithm is currently in.
		 */
		private function arcConsitancyCheck(sudokuState:Sudoku):void
		{
			//Step 1: Iterate through all variables
			//Step 2: Iterate through all items of the variable's domain
			//Step 3: Check the row, column and grid to see if using the current
			//item in the domain would cause any other variable's domainsize to turn to 0.
			//--> If this happens, remove the currently checked item in the domain.
			var variables:Array = sudokuState.getVariables();
			
			//Iterate through all variables.
			for(var i:int = 0; i < variables.length; i++)
			{
				var currentSquare:Square = variables[i];
				
				//Skip checking the square's domain if it is already locked or set.
				if(currentSquare.isLocked() || currentSquare.isSet())
					continue;
				
				//Check every variable in the square's domain.
				var remove:Array = new Array();
				for(var domainNum:int = 0; domainNum < currentSquare.getDomainSize(); domainNum++)
				{
					if(checkDomain(sudokuState, i, domainNum) == false)
						remove.push(domainNum);
				}
				
				//Update the tracking data.
				numRemovedThroughAC+= remove.length;
				
				//Remove all variables that conflict with other domains.
				while(remove.length > 0)
					currentSquare.removeFromDomain(remove.pop());
			}
		}
		
		/*
		 * Checks to see if a value would conflict with the domains of other squares.
		 * @param sudokuState The sudoku state that the algorithm is currently in.
		 * @param location The location of the square you are checking.
		 * @param valueToCheck The value you want to check every domain with.
		 * @return Returns whether or not domain is still legal after checking. 
		 */
		private function checkDomain(sudokuState:Sudoku, location:int, valueToCheck:int):Boolean
		{
			var row:int = Math.floor(location / 9);
			var column:int = location % 9;
			var variables:Array = sudokuState.getVariables();
			
			//Check the domain for each square in the same row.
			for(var i:int = 0; i < 9; i++)
			{
				//Skip if it's the same square.
				if((row * 9 + i) == location)
					continue;
				
				var sqX:Square = variables[(row * 9 + i)];
				
				//Check the square's domain if it's a square that hasn't been set or locked.
				if(sqX.isLocked() == false && sqX.isSet() == false)
				{
					if(sqX.getDomainSize() == 1)
					{
						//If there is only one item left and it matches the one we want to remove,
						//the current variable is invalid.
						if(sqX.getDomain()[0] == valueToCheck)
							return false;
					}
				}
			}
			
			//Check the domain for each square in the same column.
			for(var j:int = 0; j < 9; j++)
			{
				//Skip if it's the same square.
				if((j * 9 + column) == location)
					continue;
					
				var sqY:Square = variables[(j * 9 + column)];
				
				//Update the square's domain if it's a square that hasn't been set or locked.
				if(sqY.isLocked() == false && sqY.isSet() == false)
				{
					if(sqY.getDomainSize() == 1)
					{
						//If there is only one item left and it matches the one we want to remove,
						//the current variable is invalid.
						if(sqY.getDomain()[0] == valueToCheck)
							return false;
					}
				}
			}
			
			var gridX:int = Math.floor(column / 3) * 3;
			var gridY:int = Math.floor(row / 3) * 3;
			
			//Check the domain for each square in the same grid.
			for(var x:int = gridX; x < gridX + 3; x++)
			{
				for(var y:int = gridY; y < gridY + 3; y++)
				{
					//Skip if it's the same square.
					if((y * 9 + x) == location)
						continue;
					
					var sqGrid:Square = variables[(y * 9 + x)];
					
					//Update the square's domain if it's a square that hasn't been set or locked.
					if(sqGrid.isLocked() == false && sqGrid.isSet() == false)
					{
						if(sqGrid.getDomainSize() == 1)
						{					
							//If there is only one item left and it matches the one we want to remove,
							//the current variable is invalid.
							if(sqGrid.getDomain()[0] == valueToCheck)
								return false;
						}
					}
				}
			}
			
			//The current variable is valid.
			return true;
		}
		
		/*
		 * Refreshes the currently displayed sudoku in order to see changes on the board.
		 */
		private function refreshDisplay(currentState:Sudoku):void
		{
			//Remove the previous drawings from the stage.
			if(previousState != null)
			{
				previousState.clearDisplay();
				removeChild(previousState);
			}
					
			//Add the new sudoku to the stage and draw it.
			addChild(currentState);
			currentState.display();
			
			//Set the previous state to the current state so we can remove it later.
			previousState = currentState;
		}
		
		/*
		 * Randomly fills a board based on valid squares. It choses a random square and 
		 * looks at its domain. It picks a random item from this domain and then moves on 
		 * to the next square. 
		 * 
		 * WARNING: It is still possible to create a non-valid board using this method.
		 * The less initial amount of squares filled, the less likely the sudoku is prone to failure.
		 * 
		 * @param board The initial board to fill.
		 */
		private function generateRandom(board:Sudoku):void
		{
			var variables:Array = board.getVariables();
			
			//Generate a random initial amount of filled squares between 5 and 15.
			var begin:int = 5;
			var end:int = 15;
			var initialSquaresFilled:int = Math.floor(begin + (Math.random() * (end - begin + 1)));
			
			//Iterate through the amount of preferred squares.
			for(var i:int = 0; i < initialSquaresFilled; i++)
			{
				//Get a random square and value for that square.
				var location:int = Math.floor(Math.random() * 81);
				var square:Square = variables[location];
				
				//If the square is already set, find the very first non-set square available from this square on.
				while(square.isSet())
				{
					location++;
					
					if(location == 81)
						location = 0;
						
					square = variables[location];
				}
				
				var newValue:int = square.getDomain()[(Math.floor(Math.random() * square.getDomainSize()))];
				
				//Check if the value is possible or not. If not, remove the value from the domain and pick a new one.
				while(forwardCheck(board, location, newValue) == false)
				{
					square.removeFromDomain(newValue);
					newValue = square.getDomain()[(Math.floor(Math.random() * square.getDomainSize()))];
				}
								
				//AC3 check every square just to be sure the board is still most likely to be valid.
				for(var j:int = 0; j < 81; j++)
				{
					var currentSquare:Square = variables[i];
					for(var domainNum:int = 0; domainNum < currentSquare.getDomainSize(); domainNum++)
					{
						if(checkDomain(board, j, domainNum) == false)
						{
							board.createEmpty();
							generateRandom(board);
							return;
						}
					}
				}
				
				//If the domain's size is 0, retry the entire board.
				if(square.getDomainSize() == 0)
				{
					board.createEmpty();
					generateRandom(board);
					return;
				}
				
				//Set the square's new value seeing as it's still legal.
				square.setValue(newValue, true);
			}
		}
		
		/*
		 * Handles global errors. It is used to prevent the program from 
		 * crashing when the user uses a wong file as input.
		 * @param event The error's event. 
		 */
		private function handleGlobalErrors(event:UncaughtErrorEvent):void
		{
			//Displays the error in the textfield.
			if(inputField != null)
				inputField.text = event.error.text;
				
			//Prevent the SWF from crashing.
			event.preventDefault();
		}
	}
}
