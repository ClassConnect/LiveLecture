@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "jquery.js"
@import "highcharts.js"	//	HIGHCHARTS ARE FUCKING AWESOME. GOOD JOB HIGHCHARTS GUY!

@implementation CCHighchartLayer : CALayer
{
	JSObject _data @accessors(property=data);
	
	JSObject _chart;
	DOMElement _container;
	
	BOOL _isDirty;
	BOOL _first;
}

-(id)init
{
	if(self = [super init])
	{
		_container = document.createElement('div');
		_container.id = [self UID];
		_container.style.width = "100%";
		_container.style.height = "100%";
		self._DOMElement.appendChild(_container);
		_isDirty = YES;
		_first = YES;
		[self setAnchorPoint:CGPointMakeZero()];
	}
	return self;
}

-(void)setBounds:(CGRect)rect
{
	[super setBounds:rect];
}

-(void)setAffineTransform:(CGAffineTransform)affineTransform
{
	[super setAffineTransform:affineTransform];
}

-(void)drawInContext:(CGContext)context
{
	if(!_chart)
		[self _drawChart];
}

-(void)_drawChart
{
	_chart = new Highcharts.Chart({
			chart: {
				renderTo: [self UID]+'',
				plotBackgroundColor: null,
				plotBorderWidth: null,
				plotShadow: false
			},
			title: {
				text: ''
			},
			tooltip: {
				formatter: function() {
					return '<b>'+ this.point.name +'</b>: '+ this.y +'';
				}
			},
			plotOptions: {
				pie: {
					allowPointSelect: true,
					cursor: 'pointer',
					dataLabels: {
						enabled: false,
						color: '#000000',
						connectorColor: '#000000',
						formatter: function() {
							return '<b>'+ this.point.name +'</b>: '+ this.y +'';
						}
					}
				}
			},
		    series: [{
				type: 'pie',
				name: '',
				data: _data
			}]
		});	
	_first = NO;
	_isDirty = NO;
}

-(void)setData:(CPArray)data
{
	if([data isEqual:_data])
		return;
	_data = data;
	if(_chart)
		_chart.series[0].setData(_data);
}

-(void)datapointAtIndex:(int)index
{
	return _data[index];
}

-(void)updateDatapointAtIndex:(int)index toValue:(float)value
{
	[self updateDatapointAtIndex:index toValue:value redraw:YES];
}

-(void)updateDatapointAtIndex:(int)index toValue:(float)value redraw:(BOOL)redraw
{
	_data[index] = value;
	if(_chart)
	{
		//	Update the chart to deal with the new datapoint
		_chart.series[0].data[index].update(value,redraw);
	}
}

@end