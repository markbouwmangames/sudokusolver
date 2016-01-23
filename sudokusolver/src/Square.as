package 
{
	/**
	 * @author Mark Bouwman
	 */
	 
	 /*
	  * The Square class is used to store any given square. It is used to keep track of whatever
	  * every sqaure's domain is, and what the assigned value is. 
	  */
	public class Square 
	{
		private var currentValue:int = 0;
		private var domain:Array = new Array(1,2,3,4,5,6,7,8,9);
		private var set:Boolean = false;		
		private var locked:Boolean = false;
		private var displayCurrentlyChecked:Boolean = false;
		
		/*
		 * Set the square's current value.
		 * @param value The new value.
		 * @param locked Whether or not the square is locked from the start.
		 */
		public function setValue(value:int, locked:Boolean = false):void
		{
			if(value != 0)
				set = true;
			
			this.currentValue = value;
			this.locked = locked;
			
			if(locked)
				domain = new Array();
		}		
				
		/*
		 * Returns the square's current value.
		 * @return The square's value.
		 */
		public function getValue():int
		{
			return this.currentValue;
		}
		
		/*
		 * Returns the square's domainsize.
		 * @return The square's domainsize.
		 */
		public function getDomainSize():int
		{
			return this.domain.length;
		}
		
		/*
		 * Returns the square's domain.
		 * @return The square's domain.
		 */
		public function getDomain():Array
		{
			return this.domain;
		}
		
		/*
		 * Removes a number from the domain.
		 * @param remove The integer to remove from the domain.
		 */
		public function removeFromDomain(remove:int):void
		{
			var newDomain:Array = new Array();
			for(var i:int = 0; i < domain.length; i++)
			{
				if(domain[i] != remove)
					newDomain.push(domain[i]);
			}
			
			this.domain = newDomain;
		}
		
		/*
		 * Returns whether or not the square has a set value.
		 * @return If the square is set.
		 */
		public function isSet():Boolean
		{
			return this.set;
		}
		
		/*
		 * Set whether or not this square should light up, indicating it's currently checked.
		 * @param isChecked Set if the square should light up.
		 */
		public function setCurrentlyChecked(isChecked:Boolean):void
		{
			this.displayCurrentlyChecked = isChecked;
		}
		
		/*
		 * Returns if the square is the current checked square.
		 * @return Return if the square is the current checked square.
		 */
		public function isCurrentlyChecked():Boolean
		{
			return this.displayCurrentlyChecked;
		}
		
		/*
		 * Returns whether or not the square is locked.
		 * @return If the square is locked.
		 */
		public function isLocked():Boolean
		{
			return this.locked;
		}
		
		/*
		 * Copy all of the data from one square to the other.
		 * @param square1 The square to copy all of the data to.
		 * @param square2 The square to copy all of the data from.
		 */
		public static function Copy(square1:Square, square2:Square):void
		{
			square1.setValue(square2.currentValue, square2.isLocked());
			square1.domain = new Array();
			
			for(var i:int = 0; i < square2.getDomainSize(); i++)
			{
				square1.domain.push(square2.domain[i]);
			}
		}
	}
}
