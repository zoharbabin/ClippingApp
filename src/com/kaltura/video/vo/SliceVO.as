package com.kaltura.video.vo
{
	import flash.display.BitmapData;

	public class SliceVO
	{
		[Bindable]
		public var in_point:uint = 0;
		[Bindable]
		public var out_point:uint = 0;
		[Bindable]
		public var inpointBitmapData:BitmapData;
		[Bindable]
		public var outpointBitmapData:BitmapData;
		
		public function SliceVO(in_p:uint, out_p:uint, inBD:BitmapData, outBD:BitmapData)
		{
			in_point = in_p;
			out_point = out_p;
			inpointBitmapData = inBD;
			outpointBitmapData = outBD;
		}
		
		public function toString ():String 
		{
			return "in: "+in_point+
				" - out: "+out_point;
		}
	}
}