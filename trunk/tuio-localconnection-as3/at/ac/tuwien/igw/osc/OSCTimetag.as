package at.ac.tuwien.igw.osc {
	
	/**
	 * An OSCTimetag
	 * This is a helperclass for handling OSC timetags
	 * 
	 * @author Immanuel Bauer
	 */
	public class OSCTimetag {
		
		public var seconds:uint;
		public var picoseconds:uint;
		
		public function OSCTimetag(seconds:uint, picoseconds:uint) {
			this.seconds = seconds;
			this.picoseconds = picoseconds;
		}
		
	}
	
}