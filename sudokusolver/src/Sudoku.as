package 
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.text.TextField;
	
	/**
	 * @author Mark Bouwman
	 */
	 
	/*
	 * The Sudoku class is used to keep track of the sudoku board. It can be used 
	 * to check all rows, columns and 3x3 grids. It requires the input from a textfield in 
	 * order to be created, saving all of the characters in 'Squares'.
	 */	 
	public class Sudoku extends Sprite
	{
		private var variables:Array = new Array();
				
		/*
		 * Creates a new sudoku to use for solving.
		 * @param text The text that originated from the input file.
		 */
		public function Sudoku(text:String = null)
		{			
			if(text == null)
				return;
			
			/* Every single character is on an even number, so we iterate through the given text and 
			 * push every character at such a spot to the variables array.
			*/
			for(var i:int = 0; i < text.length; i++)
			{
				if(i % 2 == 0)
				{
					//Create a new square and push it to the variables list.
					var sq:Square = new Square();
					var lock:Boolean = false;
					
					//Lock it, seeing as it's the start of the game.
					var newValue:int = (int)(text.charAt(i));
					if(newValue != 0)
						lock = true;
						
					sq.setValue(newValue, lock);
					variables.push(sq);
				}
			}
		}
		
		/*
		 * Creates an empty set to use for generating a random sudoku.
		 */
		public function createEmpty():void
		{
			variables = new Array();
			
			//Create a new square and push it to the variables list.
			for(var i:int = 0; i < 81; i++)
			{
				var sq:Square = new Square();
				variables.push(sq);
			}
		}
		
		/*
		 * Returns the characterset. 
		 * @return The characterset. 
		 */
		public function getVariables():Array
		{
			return variables;
		}
		
		/*
		 * Returns the character at a given x,y location. 
		 * @param x The x location (column)
		 * @param y The y location (row)
		 * @return The character at the given x,y location. 
		 */
		public function getChar(x:int, y:int):int
		{
			return (variables[(y * 9 + x)] as Square).getValue();
		}
			
		/*
		 * Checks whether or not a row is valid (has no reoccuring digits)
		 * @param rowNumber The row that should be checked.
		 * @return Whether or not the row is valid
		 */
		public function isValidRow(rowNumber:int):Boolean
		{
			var checked:Array = new Array();
			for(var i:int = 0; i < 9; i++)
			{
				var current:Square = variables[(rowNumber * 9 + i)];
				var currentVal:int = current.getValue();	
					
				if(checked.length > 0)
				{
					if(currentVal != 0)
					{
						for(var j:int = 0; j < checked.length; j++)
						{
							if(currentVal == checked[j])
								return false;
						}
						
						checked.push(currentVal);
					}
					else
					{
						return false;
					}
				}
				else
				{
					checked.push(currentVal);
				}
			}
			
			return true;
		}
		
		/*
		 * Checks whether or not a column is valid (has no reoccuring digits)
		 * @param colNumber The column that should be checked.
		 * @return Whether or not the column is valid.
		 */
		public function isValidColumn(colNumber:int):Boolean
		{
			var checked:Array = new Array();
			for(var i:int = 0; i < 9; i++)
			{
				var current:Square = variables[(i * 9 + colNumber)];				
				var currentVal:int = current.getValue();	
				
				if(checked.length > 0)
				{
					if(currentVal != 0)
					{
						for(var j:int = 0; j < checked.length; j++)
						{
							if(currentVal == checked[j])
								return false;
						}
						
						checked.push(currentVal);
					}
					else
					{
						return false;
					}
				}
				else
				{
					checked.push(currentVal);
				}
			}
			
			return true;

		}
		
		/*
		 * Checks whether or not a grid (3x3) is valid (has no reoccuring digits)
		 * @param gridNum The grid that should be checked.
		 * @return Whether or not the grid is valid.
		 */
		public function isValidGrid(gridNum:int):Boolean
		{
			var startX:int = 0;
			var startY:int = 0;
			
			if(gridNum == 1)
			{
				startX = 3;
				startY = 0;
			}
			if(gridNum == 2)
			{
				startX = 6;
				startY = 0;
			}
			if(gridNum == 3)
			{
				startX = 0;
				startY = 3;
			}
			if(gridNum == 4)
			{
				startX = 3;
				startY = 3;
			}
			if(gridNum == 5)
			{
				startX = 6;
				startY = 3;
			}
			if(gridNum == 6)
			{
				startX = 0;
				startY = 6;
			}
			if(gridNum == 7)
			{
				startX = 3;
				startY = 6;
			}
			if(gridNum == 8)
			{
				startX = 6;
				startY = 6;
			}
			
			var checked:Array = new Array();
			for(var x:int = startX; x < startX + 3; x++)
			{
				for(var y:int = startY; y < startY + 3; y++)
				{
					var current:Square = variables[(y * 9 + x)];
					var currentVal:int = current.getValue();			
								
					if(checked.length > 0)
					{					
						if(currentVal != 0)
						{
							for(var j:int = 0; j < checked.length; j++)
							{
								if(currentVal == checked[j])
									return false;
							}
							
							checked.push(currentVal);
						}
						else
						{
							return false;
						}
					}
					else
					{
						checked.push(currentVal);
					}
				}
			}
			
			return true;
		}
				
		/*
		 * Displays the current Sudoku grid.
		 */
		public function display(showChecked:Boolean = true):void
		{
			var currentX:int = 0;
			var currentY:int = 0;
			
			//Draw the backgroundlines to show the 3 seperate grids.
			var background:Sprite = new Sprite();
			background.graphics.lineStyle(1);
			background.graphics.moveTo(200, 0);
			background.graphics.lineTo(200, 450);
			background.graphics.moveTo(350, 0);
			background.graphics.lineTo(350, 450);
			background.graphics.moveTo(50, 150);
			background.graphics.lineTo(500, 150);
			background.graphics.moveTo(50, 300);
			background.graphics.lineTo(500, 300);
			addChild(background);
			
			//Iterate through all squares.
			for(var i:int = 0; i < variables.length; i++)			
			{	
				//Update the display location.
				currentX += 50;
				if(i % 9 == 0 && i != 0	)
				{
					currentX = 50;
					currentY += 50;
				}
				
				var current:Square = variables[i];
								
				//Draw the background for the square.
				var squareSprite:Sprite = new Sprite();
				
				if(current.isSet() && showChecked)
					squareSprite.graphics.beginFill(0xaaaaff, 0.3);
				if(current.isLocked())
					squareSprite.graphics.beginFill(0xbb4444, 0.3);
				if(current.isCurrentlyChecked() && showChecked)
					squareSprite.graphics.beginFill(0x44ff44, 0.3);
				
				squareSprite.graphics.lineStyle(1);
				squareSprite.graphics.drawRect(currentX + 1, currentY + 1, 48, 48);
				addChild(squareSprite);
				
				//Get the domain and display it if the square is not set yet.
				if(current.isSet() == false)
				{
					var domainText:TextField = new TextField();
					var domain:Array = current.getDomain();
					for(var j:int = 0; j < current.getDomainSize(); j++)
					{
						if(j != 0 && j % 3 == 0)
							domainText.text += "\n";
							
						domainText.text += domain[j];
						
						domainText.x = currentX;
						domainText.y = currentY + 2;
						domainText.selectable = false;
						
						squareSprite.addChild(domainText);
					}
				}
				
				//Get the current value and display it.
				var valueText:TextField = new TextField();
				valueText.text = current.getValue().toString();
				
				valueText.x = currentX + 32;
				valueText.y = currentY + 17;
				valueText.selectable = false;
				
				//Center the text if there is no domain to show
				if(current.isLocked() || current.isSet())
					valueText.x -= 11;
					
				squareSprite.addChild(valueText);
			}
		}
		
		/*
		 * Removes the current Sudoku grid.
		 */
		public function clearDisplay():void
		{
			//Iterate through all children.
			while(this.numChildren > 0)
			{
				//Remove the child from the stage and set it to null.
				var child:DisplayObject = this.getChildAt(0);
				removeChild(child);
				child = null;
			}
		}
		
		/*
		 * A basic function to check whether or not the sudoku is valid.
		 * @return If the sudoku is valid.
		 */
		public function isLegalSudoku():Boolean
		{
			for(var i:int = 0; i < 9; i++)
			{
				var validRow:Boolean = this.isValidRow(i);
				var validCol:Boolean = this.isValidColumn(i);
				var validGrid:Boolean = this.isValidGrid(i);
				
				if(!validRow || !validCol || !validGrid)
					return false;
			}
			
			return true;
		}
		
		/*
		 * Copy all of the data from one sudoku to the other.
		 * @param sudoku1 The sudoku to copy all of the data to.
		 * @param sudoku2 The sudoku to copy all of the data from.
		 */
		public static function Copy(sudoku1:Sudoku, sudoku2:Sudoku):void
		{
			sudoku1.variables = new Array();
			
			for(var i:int = 0; i < sudoku2.variables.length; i++)
			{
				var square1:Square = new Square;
				var square2:Square = (Square)(sudoku2.variables[i]);
				Square.Copy(square1, square2);
				sudoku1.variables.push(square1);
			}
		}
	}
}
