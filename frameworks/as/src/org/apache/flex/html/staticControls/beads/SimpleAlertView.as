////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.flex.html.staticControls.beads
{
	import org.apache.flex.core.IAlertModel;
	import org.apache.flex.core.IBead;
    import org.apache.flex.core.IBeadView;
	import org.apache.flex.core.IMeasurementBead;
	import org.apache.flex.core.IStrand;
    import org.apache.flex.core.IParent;
	import org.apache.flex.core.UIBase;
	import org.apache.flex.core.UIMetrics;
	import org.apache.flex.core.ValuesManager;
	import org.apache.flex.events.Event;
	import org.apache.flex.events.IEventDispatcher;
	import org.apache.flex.html.staticControls.Label;
	import org.apache.flex.html.staticControls.TextButton;
	import org.apache.flex.utils.BeadMetrics;
	
	public class SimpleAlertView implements IBeadView
	{
		public function SimpleAlertView()
		{
		}
		
		private var messageLabel:Label;
		private var okButton:TextButton;
		
		private var _strand:IStrand;
		public function set strand(value:IStrand):void
		{
			_strand = value;
            
			var backgroundColor:Object = ValuesManager.valuesImpl.getValue(value, "background-color");
			var backgroundImage:Object = ValuesManager.valuesImpl.getValue(value, "background-image");
			if (backgroundColor != null || backgroundImage != null)
			{
				if (value.getBeadByType(IBackgroundBead) == null)
					value.addBead(new (ValuesManager.valuesImpl.getValue(value, "iBackgroundBead")) as IBead);					
			}
			
			var borderStyle:String;
			var borderStyles:Object = ValuesManager.valuesImpl.getValue(value, "border");
			if (borderStyles is Array)
			{
				borderStyle = borderStyles[1];
			}
			if (borderStyle == null)
			{
				borderStyle = ValuesManager.valuesImpl.getValue(value, "border-style") as String;
			}
			if (borderStyle != null && borderStyle != "none")
			{
				if (value.getBeadByType(IBorderBead) == null)
					value.addBead(new (ValuesManager.valuesImpl.getValue(value, "iBorderBead")) as IBead);	
			}
			
			var model:IAlertModel = _strand.getBeadByType(IAlertModel) as IAlertModel;
			model.addEventListener("messageChange",handleMessageChange);
			model.addEventListener("htmlMessageChange",handleMessageChange);

            messageLabel = new Label();
			messageLabel.text = model.message;
			messageLabel.html = model.htmlMessage;
			IParent(_strand).addElement(messageLabel);
			
			okButton = new TextButton();
			okButton.text = model.okLabel;
			IParent(_strand).addElement(okButton);
			okButton.addEventListener("click",handleOK);
			
			handleMessageChange(null);
		}
		
		private function handleMessageChange(event:Event):void
		{
			var ruler:IMeasurementBead = messageLabel.getBeadByType(IMeasurementBead) as IMeasurementBead;
			if( ruler == null ) {
				messageLabel.addBead(ruler = new (ValuesManager.valuesImpl.getValue(messageLabel, "iMeasurementBead")) as IMeasurementBead);
			}
			var maxWidth:Number = Math.max(UIBase(_strand).width,ruler.measuredWidth);
			
			var metrics:UIMetrics = BeadMetrics.getMetrics(_strand);
			
			messageLabel.x = metrics.left;
			messageLabel.y = metrics.top;
			messageLabel.width = maxWidth;
			
			okButton.x = (maxWidth - okButton.width)/2;
			okButton.y = messageLabel.y + messageLabel.height + 20;
			
			UIBase(_strand).width = maxWidth + metrics.left + metrics.right;
			UIBase(_strand).height = okButton.y + okButton.height + metrics.bottom;
		}
		
		private function handleOK(event:Event):void
		{
			var newEvent:Event = new Event("close");
			IEventDispatcher(_strand).dispatchEvent(newEvent);
		}
	}
}