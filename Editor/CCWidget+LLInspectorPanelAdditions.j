@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>
@import "../CoreLecture/CoreLecture.j"

@implementation CCWidget (LLInspectorPanelAdditions)

//	Should turn something like CCTextWidget into CCTextWidgetInspectorContentView
+(Class)inspectorContentViewClass
{
	return CPClassFromString(CPStringFromClass(self) + "InspectorContentView");
}

@end