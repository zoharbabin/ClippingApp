package com.kaltura.video.vo
{
	public class SliceVO
	{
		public var in_point:uint = 0;
		public var out_point:uint = 0;
		
		public function SliceVO(in_p:uint, out_p:uint)
		{
			in_point = in_p;
			out_point = out_p;
		}
		
		public function toString ():String 
		{
			return "in: "+in_point+
				" - out: "+out_point;
		}
	}
}