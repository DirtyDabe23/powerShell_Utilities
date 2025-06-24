param(
    [string]$jiraTicket
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::'Tls13','TLS12'
$PSStyle.OutputRendering = [System.Management.Automation.OutputRendering]::PlainText
$errorsToReviewJSON = @'
[
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.<CalculateFreightCommandExecuted>",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.<CalculateFreightCommandExecuted>*",
    "Tag": "ERR_NULLEXCEP_CalculateFreightCommandExecuted",
    "NumberOfCrashes": "45"
  },
  {
    "ClassName": "System.Runtime.InteropServices.COMException",
    "Message": "UCEERR_RENDERTHREADFAILURE (Exception from HRESULT: 0x88980406)",
    "StackTraceString": "at System.Windows.Media.Composition.DUCE.Channel.SyncFlush()",
    "SearchString": "*System.Windows.Media.Composition.DUCE*",
    "Tag": "ERR_COMException_SyncFlush",
    "NumberOfCrashes": "23"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.MakeOppQuoteCommandCanExecute()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.MakeOppQuoteCommandCanExecute()*",
    "Tag": "ERR_NULLEXCEP_MakeOppQuoteCommandCanExecute",
    "NumberOfCrashes": "18"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "Insufficient memory to continue the execution of the program.",
    "StackTraceString": "at System.Windows.Xps.Serialization.RCW.IXpsOMPackageWriter.Close()",
    "SearchString": "*at System.Windows.Xps.Serialization.RCW.IXpsOMPackageWriter.Close()*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "Insufficient memory to continue the execution of the program.",
    "StackTraceString": "at System.Windows.Media.Renderer.Render(IntPtr pRenderTarget, Channel channel, Visual visual, Int32 width, Int32 height, Double dpiX, Double dpiY, Matrix worldTransform, Rect windowClip)",
    "SearchString": "*at System.Windows.Media.Renderer.Render(IntPtr pRenderTarget, Channel channel, Visual visual, Int32 width, Int32 height, Double dpiX, Double dpiY, Matrix worldTransform, Rect windowClip)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "Exception has been thrown by the target of an invocation.",
    "StackTraceString": "at System.Collections.Generic.List`1.set_Capacity(Int32 value)\\r\\n   at System.Collections.Generic.List`1.EnsureCapacity(Int32 min)",
    "SearchString": "*at System.Collections.Generic.List`1.set_Capacity(Int32 value)\\r\\n   at System.Collections.Generic.List`1.EnsureCapacity(Int32 min)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "",
    "StackTraceString": "t Evapco.CRM.Core.Models.Helpers.ValidatableBindableBase.TryValidateProperty(PropertyInfo propertyInfo, List`1 propertyErrors)",
    "SearchString": "*t Evapco.CRM.Core.Models.Helpers.ValidatableBindableBase.TryValidateProperty(PropertyInfo propertyInfo, List`1 propertyErrors)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "Exception has been thrown by the target of an invocation.",
    "StackTraceString": " at System.Collections.Generic.Dictionary`2.Resize(Int32 newSize, Boolean forceNewHashCodes)",
    "SearchString": "* at System.Collections.Generic.Dictionary`2.Resize(Int32 newSize, Boolean forceNewHashCodes)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "",
    "StackTraceString": "at Telerik.Windows.Documents.Fixed.UI.ContentElementsPainter.DrawPath(DrawingContext drawingContext, ContentElementsPainterInitializeContext context, Path path)",
    "SearchString": "*at Telerik.Windows.Documents.Fixed.UI.ContentElementsPainter.DrawPath(DrawingContext drawingContext, ContentElementsPainterInitializeContext context, Path path)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "",
    "StackTraceString": "at System.Windows.Media.Animation.TimelineGroup.AllocateClock()",
    "SearchString": "*at System.Windows.Media.Animation.TimelineGroup.AllocateClock()*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.OutOfMemoryException",
    "Message": "",
    "StackTraceString": "at System.Windows.DependencyObject.InsertEntry(EffectiveValueEntry entry, UInt32 entryIndex)",
    "SearchString": "*at System.Windows.DependencyObject.InsertEntry(EffectiveValueEntry entry, UInt32 entryIndex)*",
    "Tag": "ERR_OutOfMemoryException",
    "NumberOfCrashes": "11"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.initializeEquipmentScheduleData()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.initializeEquipmentScheduleData()*",
    "Tag": "ERR_NULLEXCEP_InitializeEquipmentScheduleData",
    "NumberOfCrashes": "10"
  },
  {
    "ClassName": "System.Exception",
    "Message": "An exception has occurred while communicating with the Server.\\r\\nMessage: An error has occurred.\\r\\nException Type: \\r\\nException Message: \\r\\nStack Trace: \\r\\n",
    "StackTraceString": "at Evapco.CRM.Client.ServiceProxies.BaseHttpRemoteServiceProxy.EvaluateResponseStatusCode(HttpResponseMessage responseMessage)",
    "SearchString": "*at Evapco.CRM.Client.ServiceProxies.BaseHttpRemoteServiceProxy.EvaluateResponseStatusCode(HttpResponseMessage responseMessage)*",
    "Tag": "ERR_ServerCom_EvaluateResponseStatusCode",
    "NumberOfCrashes": "10"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Nito.AsyncEx.NotifyTaskCompletion.NotifyTaskCompletionImplementation`1..ctor(Task`1 task)\\r\\n   at Void .ctor(System.Threading.Tasks.Task`1[System.Collections.Generic.IEnumerable`1[System.Tuple`2",
    "SearchString": "*at Nito.AsyncEx.NotifyTaskCompletion.NotifyTaskCompletionImplementation`1..ctor(Task`1 task)\\r\\n   at Void .ctor(System.Threading.Tasks.Task`1[System.Collections.Generic.IEnumerable`1[System.Tuple`2*",
    "Tag": "ERR_NULLEXCEP_Nito.AsyncEx",
    "NumberOfCrashes": "9"
  },
  {
    "ClassName": "System.Net.WebException",
    "Message": "The remote name could not be resolved: 'crm.evapco.com'",
    "StackTraceString": "at System.Net.HttpWebRequest.EndGetRequestStream(IAsyncResult asyncResult, TransportContext& context)",
    "SearchString": "*at System.Net.HttpWebRequest.EndGetRequestStream(IAsyncResult asyncResult, TransportContext& context)*",
    "Tag": "ERR_WEBEXCEPTION",
    "NumberOfCrashes": "8"
  },
  {
    "ClassName": "System.InvalidOperationException",
    "Message": "Sequence contains no matching element",
    "StackTraceString": "at System.Linq.Enumerable.First[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectAccessoriesViewModel.UpdateTrayItems()",
    "SearchString": "*at System.Linq.Enumerable.First[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectAccessoriesViewModel.UpdateTrayItems()*",
    "Tag": "ERR_InvalidOp_UpdateTrayItems",
    "NumberOfCrashes": "7"
  },
  {
    "ClassName": "System.ObjectDisposedException",
    "Message": "Cannot access a closed Stream.",
    "StackTraceString": "at System.IO.__Error.StreamIsClosed()\\r\\n   at System.IO.MemoryStream.Write(Byte[] buffer, Int32 offset, Int32 count)\\r\\n   at System.IO.StreamWriter.Flush",
    "SearchString": "*at System.IO.__Error.StreamIsClosed()\\r\\n   at System.IO.MemoryStream.Write(Byte[] buffer, Int32 offset, Int32 count)\\r\\n   at System.IO.StreamWriter.Flush*",
    "Tag": "ERR_ObjectDisposedException",
    "NumberOfCrashes": "5"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.MenuItemDocumentsOrderCommandExecuted(Object obj)",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.MenuItemDocumentsOrderCommandExecuted(Object obj)*",
    "Tag": "ERR_NULLEXCEP_MenuItemDocumentsOrderCommandExecuted",
    "NumberOfCrashes": "5"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Core.Models.AuthenticatedBaseViewModel.ToolbarDuplicateOrderCommandCanExecute()",
    "SearchString": "* at Evapco.CRM.Client.Core.Models.AuthenticatedBaseViewModel.ToolbarDuplicateOrderCommandCanExecute()*",
    "Tag": "ERR_NULLEXCEP_ToolbarDuplicateOrderCommandCanExecute",
    "NumberOfCrashes": "4"
  },
  {
    "ClassName": "System.ArgumentNullException",
    "Message": "Value cannot be null.",
    "StackTraceString": "at System.Linq.Enumerable.Where[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.CustomerSearchCommandExecuted()",
    "SearchString": "*at System.Linq.Enumerable.Where[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.CustomerSearchCommandExecuted()*",
    "Tag": "ERROR_ARGNULL_CustomerSearchCommandExecuted",
    "NumberOfCrashes": "4"
  },
  {
    "ClassName": "System.InvalidOperationException",
    "Message": "Nullable object must have a value",
    "StackTraceString": "at System.ThrowHelper.ThrowInvalidOperationException(ExceptionResource resource)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.CalculateFreightCompleted(Object sender, RunWorkerCompletedEventArgs e)",
    "SearchString": "*at System.ThrowHelper.ThrowInvalidOperationException(ExceptionResource resource)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.CalculateFreightCompleted(Object sender, RunWorkerCompletedEventArgs e)*",
    "Tag": "ERR_InvalidOp_CalculateFreightCompleted",
    "NumberOfCrashes": "4"
  },
  {
    "ClassName": "System.Net.Sockets.SocketException",
    "Message": "No connection could be made because the target machine actively refused it",
    "StackTraceString": "at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)\\r\\n   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)",
    "SearchString": "*at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)\\r\\n   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)*",
    "Tag": "ERR_SOCKETEXCEPTION",
    "NumberOfCrashes": "3"
  },
  {
    "ClassName": "System.Net.Sockets.SocketException",
    "Message": "A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond",
    "StackTraceString": "at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)\\r\\n   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)",
    "SearchString": "*at System.Net.Sockets.Socket.InternalEndConnect(IAsyncResult asyncResult)\\r\\n   at System.Net.Sockets.Socket.EndConnect(IAsyncResult asyncResult)*",
    "Tag": "ERR_SOCKETEXCEPTION",
    "NumberOfCrashes": "3"
  },
  {
    "ClassName": "System.ArgumentNullException",
    "Message": "Value cannot be null.",
    "StackTraceString": "at System.Linq.Enumerable.Where[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Core.Models.BaseCriteriaViewModel.ReloadZonesCommandExecuted()",
    "SearchString": "*at System.Linq.Enumerable.Where[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Core.Models.BaseCriteriaViewModel.ReloadZonesCommandExecuted()*",
    "Tag": "ERROR_ARGNULL_ReloadZonesCommandExecuted",
    "NumberOfCrashes": "3"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.MultipleCoilConfigurationCommandCanExecute()",
    "SearchString": "*at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.MultipleCoilConfigurationCommandCanExecute()*",
    "Tag": "ERR_NULLEXCEP_MultipleCoilConfigurationCommandCanExecute",
    "NumberOfCrashes": "3"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.SharedViews.ViewModels.SmartShieldViewModel.ApplyCommand()",
    "SearchString": "*at Evapco.CRM.Client.Modules.SharedViews.ViewModels.SmartShieldViewModel.ApplyCommand()*",
    "Tag": "ERR_NULLEXCEP_SmartShieldApplyCommand",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.OrderWaterTreatmentCommandCanExecute()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.OrderWaterTreatmentCommandCanExecute()*",
    "Tag": "ERR_NULLEXCEP_OrderWaterTreatmentCommandCanExecute",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Selection.ViewModels.SelectionAccessoriesViewModel.UpdateTrayItems()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Selection.ViewModels.SelectionAccessoriesViewModel.UpdateTrayItems()*",
    "Tag": "ERR_NULLEXCEP_UpdateTrayItems",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.ArgumentOutOfRangeException",
    "Message": "Index was out of range. Must be non-negative and less than the size of the collection.",
    "StackTraceString": "at System.ThrowHelper.ThrowArgumentOutOfRangeException(ExceptionArgument argument, ExceptionResource resource)\\r\\n   at System.Collections.Generic.List`1.get_Item(Int32 index)\\r\\n   at Evapco.CRM.Client.Core.Controls.HierarchicalTreeViewControl.EnableMenuBasedOnRole()\\r\\n   at Evapco.CRM.Client.Core.Controls.HierarchicalTreeViewControl.set_Categories(IEnumerable`1 value)",
    "SearchString": "*at System.ThrowHelper.ThrowArgumentOutOfRangeException(ExceptionArgument argument, ExceptionResource resource)\\r\\n   at System.Collections.Generic.List`1.get_Item(Int32 index)\\r\\n   at Evapco.CRM.Client.Core.Controls.HierarchicalTreeViewControl.EnableMenuBasedOnRole()\\r\\n   at Evapco.CRM.Client.Core.Controls.HierarchicalTreeViewControl.set_Categories(IEnumerable`1 value)*",
    "Tag": "ERR_ARGRANGE_set_Categories",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.IndexOutOfRangeException",
    "Message": "Index was outside the bounds of the array.",
    "StackTraceString": "at Telerik.Windows.Controls.GridView.GridViewVirtualizingPanel.FlatLayoutStrategy.RealizeMergedCells(Double frozenOffset, IEnumerable`1 mergedCells)",
    "SearchString": "*at Telerik.Windows.Controls.GridView.GridViewVirtualizingPanel.FlatLayoutStrategy.RealizeMergedCells(Double frozenOffset, IEnumerable`1 mergedCells)*",
    "Tag": "ERR_IndexRange_RealizeMergedCells",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.InvalidOperationException",
    "Message": "Sequence contains no elements",
    "StackTraceString": "at System.Linq.Enumerable.First[TSource](IEnumerable`1 source)\\r\\n   at Evapco.CRM.Client.Modules.SharedViews.ViewModels.PulsePureViewModel.RefreshPulsePureCommandExecuted()",
    "SearchString": "*at System.Linq.Enumerable.First[TSource](IEnumerable`1 source)\\r\\n   at Evapco.CRM.Client.Modules.SharedViews.ViewModels.PulsePureViewModel.RefreshPulsePureCommandExecuted()*",
    "Tag": "ERR_InvalidOp_RefreshPulsePureCommandExecuted",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.InvalidOperationException",
    "Message": "Sequence contains no matching element",
    "StackTraceString": "at System.Linq.Enumerable.First[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Core.Context.ProjectContext.get_SelectedCustomer()\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.ApplySaveOrderCommandExecuted()",
    "SearchString": "*at System.Linq.Enumerable.First[TSource](IEnumerable`1 source, Func`2 predicate)\\r\\n   at Evapco.CRM.Client.Core.Context.ProjectContext.get_SelectedCustomer()\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.ApplySaveOrderCommandExecuted()*",
    "Tag": "ERR_InvalidOp_ApplySaveOrderCommandExecuted",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Core.Models.AuthenticatedBaseViewModel.ReplaceLineItemCommandCanExecute(Nullable`1 addWaterTreatment)",
    "SearchString": "*at Evapco.CRM.Client.Core.Models.AuthenticatedBaseViewModel.ReplaceLineItemCommandCanExecute(Nullable`1 addWaterTreatment)*",
    "Tag": "ERR_NULLEXCEP_ReplaceLineItemCommandCanExecute",
    "NumberOfCrashes": "2"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.EditProjectEquipmentCommandExecuted()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.EditProjectEquipmentCommandExecuted()*",
    "Tag": "ERR_NULLEXCEP_EditProjectEquipmentCommandExecuted",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.ComponentModel.Win32Exception",
    "Message": "The parameter is incorrect",
    "StackTraceString": "at MS.Win32.UnsafeNativeMethods.GetWindowTextLength(HandleRef hWnd)\\r\\n   at MS.Win32.UnsafeNativeMethods.GetWindowTextNoThrow",
    "SearchString": "*at MS.Win32.UnsafeNativeMethods.GetWindowTextLength(HandleRef hWnd)\\r\\n   at MS.Win32.UnsafeNativeMethods.GetWindowTextNoThrow*",
    "Tag": "ERR_Win32Exception_GetWindowTextLength",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.Exception",
    "Message": "Unable to Deserialize Json Http Response::HttpStatusCode=ServiceUnavailable::HttpResponse RawData=<!DOCTYPE HTML PUBLIC \\\"-//W3C//DTD HTML 4.01//EN\\\"\\\"http://www.w3.org/TR/html4/strict.dtd\\\">\\r\\n<HTML><HEAD><TITLE>Service Unavailable",
    "StackTraceString": "at Newtonsoft.Json.JsonTextReader.ParseValue()\\r\\n   at Newtonsoft.Json.JsonTextReader.Read()",
    "SearchString": "*at Newtonsoft.Json.JsonTextReader.ParseValue()\\r\\n   at Newtonsoft.Json.JsonTextReader.Read()*",
    "Tag": "ERR_ServiceUnavailable_ParseValue",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Core.Models.BaseCriteriaViewModel.ReloadZonesCommandExecuted()",
    "SearchString": "*at Evapco.CRM.Client.Core.Models.BaseCriteriaViewModel.ReloadZonesCommandExecuted()*",
    "Tag": "ERR_NULLEXCEP_ReloadZonesCommandExecuted",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.ShowSubmitOrderCommandCanExecute()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.ShowSubmitOrderCommandCanExecute()*",
    "Tag": "ERR_NULLEXCEP_ShowSubmitOrderCommandCanExecute",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.IndexOutOfRangeException",
    "Message": "Index was outside the bounds of the array.",
    "StackTraceString": "at HtmlTextBlock.HtmlUpdater.Update(HtmlTagTree tagTree)\\r\\n   at HtmlTextBlock.HtmlTextBlock.Parse(String html)",
    "SearchString": "* at HtmlTextBlock.HtmlUpdater.Update(HtmlTagTree tagTree)\\r\\n   at HtmlTextBlock.HtmlTextBlock.Parse(String html)*",
    "Tag": "ERR_IndexRange_Parse",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.Resources.MissingManifestResourceException",
    "Message": "Could not find any resources appropriate for the specified culture or the neutral culture.  Make sure \\\"Telerik.Windows.Controls.GridView.Strings.resources\\\" was correctly embedded or linked into assembly \\\"Telerik.Windows.Controls.GridView\\\" at compile time, or that all the satellite assemblies required are loadable and fully signed.",
    "StackTraceString": "at System.Resources.ManifestBasedResourceGroveler.HandleResourceStreamMissing(String fileName)",
    "SearchString": "*at System.Resources.ManifestBasedResourceGroveler.HandleResourceStreamMissing(String fileName)*",
    "Tag": "ERR_MissingManifestResource",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.DoesOrderHavePriceChange()",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.DoesOrderHavePriceChange()*",
    "Tag": "ERR_NULLEXCEP_DoesOrderHavePriceChange",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.Reselect()",
    "SearchString": "*at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.Reselect()*",
    "Tag": "ERR_NULLEXCEP_Reselect",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.InvalidOperationException",
    "Message": "The stream was already consumed. It cannot be read again.",
    "StackTraceString": "at System.Net.Http.StreamContent.PrepareContent()",
    "SearchString": "*at System.Net.Http.StreamContent.PrepareContent()*",
    "Tag": "ERR_InvalidOp_PrepareContent",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.ApplyCustomChangesCommandExecuted()",
    "SearchString": "*at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.ApplyCustomChangesCommandExecuted()*",
    "Tag": "ERR_NULLEXCEP_ApplyCustomChangesCommandExecuted",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.ArgumentOutOfRangeException",
    "Message": "Index was out of range. Must be non-negative and less than the size of the collection.",
    "StackTraceString": "at System.ThrowHelper.ThrowArgumentOutOfRangeException(ExceptionArgument argument, ExceptionResource resource)\\r\\n   at System.Collections.Generic.List`1.get_Item(Int32 index)\\r\\n   at System.Linq.Enumerable.ElementAt[TSource](IEnumerable`1 source, Int32 index)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.LoadLookupDataCompleted(Object sender, RunWorkerCompletedEventArgs e)",
    "SearchString": "*at System.ThrowHelper.ThrowArgumentOutOfRangeException(ExceptionArgument argument, ExceptionResource resource)\\r\\n   at System.Collections.Generic.List`1.get_Item(Int32 index)\\r\\n   at System.Linq.Enumerable.ElementAt[TSource](IEnumerable`1 source, Int32 index)\\r\\n   at Evapco.CRM.Client.Modules.Project.ViewModels.FreightViewModel.LoadLookupDataCompleted(Object sender, RunWorkerCompletedEventArgs e)*",
    "Tag": "ERR_ARGRANGE_LoadLookupDataCompleted",
    "NumberOfCrashes": "1"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.RefreshDocuments()",
    "SearchString": "*at Evapco.CRM.Client.Modules.SharedViews.ViewModels.AccessoriesViewModel.RefreshDocuments()*",
    "Tag": "ERR_NULLEXCEP_RefreshDocuments",
    "NumberOfCrashes": "0"
  },
  {
    "ClassName": "System.Windows.Markup.XamlParseException",
    "Message": "Index was outside the bounds of the array.",
    "StackTraceString": "at System.Windows.FrameworkTemplate.LoadTemplateXaml(XamlReader templateReader, XamlObjectWriter currentWriter)",
    "SearchString": "*at System.Windows.FrameworkTemplate.LoadTemplateXaml(XamlReader templateReader, XamlObjectWriter currentWriter)*",
    "Tag": "ERR_XamlParseException",
    "NumberOfCrashes": "0"
  },
  {
    "ClassName": "System.Runtime.CompilerServices.RuntimeWrappedException",
    "Message": "An object that does not derive from System.Exception has been wrapped in a RuntimeWrappedException.",
    "StackTraceString": "at System.Printing.InternalPrintSystemException.ThrowIfNotCOMSuccess(Int32 hresultCode)",
    "SearchString": "*at System.Printing.InternalPrintSystemException.ThrowIfNotCOMSuccess(Int32 hresultCode)*",
    "Tag": "ERR_RuntimeWrapped",
    "NumberOfCrashes": "0"
  },
  {
    "ClassName": "System.NullReferenceException",
    "Message": "Object reference not set to an instance of an object.",
    "StackTraceString": "at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.SelectedQuoteChanged(EventAggregatorEventArgument args)",
    "SearchString": "*at Evapco.CRM.Client.Modules.Project.ViewModels.ProjectMainViewModel.SelectedQuoteChanged(EventAggregatorEventArgument args)",
    "Tag": "ERR_NULLEXCEP_SelectedQuoteChanged",
    "NumberOfCrashes": ""
  }
] 
'@
$errorsToReview = $errorsToReviewJSON | ConvertFrom-Json
#JiraConnection     
try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $connection | out-null
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "US-TT-Vault" -Name "JiraAPI" -AsPlainText
}
catch {
    $errorMessage = $_  
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}
#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$errorMatch = $false

$ticketNum = $jiraTicket
$form = Invoke-RestMethod -Method Get -Uri "https://evapco.atlassian.net/rest/api/2/issue/$ticketNum" -Body $jsonPayload -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
$attachment = $form.fields.attachment | Where-Object { $_.filename -eq 'log.txt' }

if ($attachment) {
    $attachmentContent = Invoke-RestMethod -Uri $attachment[0].content -Method Get -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 

    foreach ($errorToReview in $errorsToReview) {
        # Escape special characters in the search string
        $escapedSearchString= [regex]::Escape($errorToReview.StackTraceString)
        
        if ($attachmentContent.exception -match $escapedSearchString) {
            $errorMatch = $true
            $ticketsMatching += [PSCustomObject]@{
                TicketNumber = $ticketNum
                DateCreated  = $form.fields.created
                ErrorType    = $errorToReview.Tag
                reporterDisplayName = $form.fields.reporter.displayName
                reporterEmailAddress = $form.fields.reporter.emailaddress
            }
            $payload = @{
"update" = @{
    "labels" = @(@{
        "add" = "$($errorToReview.Tag)"
    })
}
}
$jsonPayload = $payload | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
            Continue
        }
    }
    If ($errorMatch -eq $false)
    {
        $payload = @{
            "update" = @{
                "labels" = @(@{
                    "add" = "ERR_NEEDS_INVESTIGATED"
                })
            }
            }
            $jsonPayload = $payload | ConvertTo-Json -Depth 10
            
            Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/json" -SslProtocol Tls12 -HttpVersion 2.0 
    }
}
Else{
    $payload = @{
        "update" = @{
            "labels" = @(@{
                "add" = "ERR_NO_ATTACHMENT"
            })
        }
        }
        $jsonPayload = $payload | ConvertTo-Json -Depth 10
        
        Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $headers -ContentType "application/JSON" -SslProtocol Tls12 -HttpVersion 2.0 
}
Write-Output "Error for $jiraTicket was: $($errorToReview.Tag)"
# SIG # Begin signature block
# MIIumQYJKoZIhvcNAQcCoIIuijCCLoYCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAZh+7D4H2NznFD
# N9d0++XV5PgTAh6QyaB3rBPoGnUoGKCCFAUwggWQMIIDeKADAgECAhAFmxtXno4h
# MuI5B72nd3VcMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0xMzA4MDExMjAwMDBaFw0z
# ODAxMTUxMjAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3EMB/z
# G6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKyunWZ
# anMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsFxl7s
# Wxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU15zHL
# 2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJBMtfb
# BHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObURWBf3
# JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6nj3c
# AORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxBYKqx
# YxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5SUUd0
# viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+xq4aL
# T8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjQjBAMA8GA1Ud
# EwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgGGMB0GA1UdDgQWBBTs1+OC0nFdZEzf
# Lmc/57qYrhwPTzANBgkqhkiG9w0BAQwFAAOCAgEAu2HZfalsvhfEkRvDoaIAjeNk
# aA9Wz3eucPn9mkqZucl4XAwMX+TmFClWCzZJXURj4K2clhhmGyMNPXnpbWvWVPjS
# PMFDQK4dUPVS/JA7u5iZaWvHwaeoaKQn3J35J64whbn2Z006Po9ZOSJTROvIXQPK
# 7VB6fWIhCoDIc2bRoAVgX+iltKevqPdtNZx8WorWojiZ83iL9E3SIAveBO6Mm0eB
# cg3AFDLvMFkuruBx8lbkapdvklBtlo1oepqyNhR6BvIkuQkRUNcIsbiJeoQjYUIp
# 5aPNoiBB19GcZNnqJqGLFNdMGbJQQXE9P01wI4YMStyB0swylIQNCAmXHE/A7msg
# dDDS4Dk0EIUhFQEI6FUy3nFJ2SgXUE3mvk3RdazQyvtBuEOlqtPDBURPLDab4vri
# RbgjU2wGb2dVf0a1TD9uKFp5JtKkqGKX0h7i7UqLvBv9R0oN32dmfrJbQdA75PQ7
# 9ARj6e/CVABRoIoqyc54zNXqhwQYs86vSYiv85KZtrPmYQ/ShQDnUBrkG5WdGaG5
# nLGbsQAe79APT0JsyQq87kP6OnGlyE0mpTX9iV28hWIdMtKgK1TtmlfB2/oQzxm3
# i0objwG2J5VT6LaJbVu8aNQj6ItRolb58KaAoNYes7wPD1N1KarqE3fk3oyBIa0H
# EEcRrYc9B9F1vM/zZn4wggawMIIEmKADAgECAhAIrUCyYNKcTJ9ezam9k67ZMA0G
# CSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0
# IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0zNjA0MjgyMzU5NTla
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDVtC9C
# 0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0JAfhS0/TeEP0F9ce
# 2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJrQ5qZ8sU7H/Lvy0da
# E6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhFLqGfLOEYwhrMxe6T
# SXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+FLEikVoQ11vkunKoA
# FdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh3K3kGKDYwSNHR7Oh
# D26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJwZPt4bRc4G/rJvmM
# 1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQayg9Rc9hUZTO1i4F4z
# 8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbIYViY9XwCFjyDKK05
# huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchApQfDVxW0mdmgRQRNY
# mtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRroOBl8ZhzNeDhFMJlP
# /2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IBWTCCAVUwEgYDVR0T
# AQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+YXsIiGX0TkIwHwYD
# VR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0PAQH/BAQDAgGGMBMG
# A1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAkBggrBgEFBQcwAYYY
# aHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAChjVodHRwOi8vY2Fj
# ZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNydDBDBgNV
# HR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRU
# cnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAEDMAgGBmeBDAEEATAN
# BgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql+Eg08yy25nRm95Ry
# sQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFFUP2cvbaF4HZ+N3HL
# IvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1hmYFW9snjdufE5Btf
# Q/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3RywYFzzDaju4ImhvTnh
# OE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5UbdldAhQfQDN8A+KVssIh
# dXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw8MzK7/0pNVwfiThV
# 9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnPLqR0kq3bPKSchh/j
# wVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatEQOON8BUozu3xGFYH
# Ki8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bnKD+sEq6lLyJsQfmC
# XBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQjiWQ1tygVQK+pKHJ6l
# /aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbqyK+p/pQd52MbOoZW
# eE4wgge5MIIFoaADAgECAhAOeHFNrWpQadD+X7fviblJMA0GCSqGSIb3DQEBCwUA
# MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFBMD8GA1UE
# AxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5NiBTSEEz
# ODQgMjAyMSBDQTEwHhcNMjQxMTEyMDAwMDAwWhcNMjUxMTEyMjM1OTU5WjCBwTET
# MBEGCysGAQQBgjc8AgEDEwJVUzEZMBcGCysGAQQBgjc8AgECEwhNYXJ5bGFuZDEd
# MBsGA1UEDwwUUHJpdmF0ZSBPcmdhbml6YXRpb24xEjAQBgNVBAUTCUQwMDY2ODUz
# MzELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE1hcnlsYW5kMRIwEAYDVQQHEwlUYW5l
# eXRvd24xEzARBgNVBAoTCkV2YXBjbyBJbmMxEzARBgNVBAMTCkV2YXBjbyBJbmMw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC4VmB16u7QUgi83PhnLWjD
# oSTpgThLIDktbX4jcd5iGW2EIcARhLhX7iUEamx07U9bQgFAElu145EAozu/h/Ed
# KmK6ij2NWOeiv7le/1LlElR+5A5zxYETPArZvETgBa0aORcVZ6MZogWcoSCUH9uo
# 64yLR7rCUAFYjLwfWfnMrjFclOhmzHhQdkrhz527pJbOIPjJFNITmM6RhYzTq02L
# 0fPq7oIkL5eXgkFljr90IUDj5mL5aqRgTUzMEfTWBJYeBkA+lS6xaPyPhFtQazxi
# Rel1K+kyD+1ohzgUOWXIO3RiQKCgWeuVJZMQrS1+ODcFba/hepMT8MKDNGwXeSc5
# RHNJ2mCkdbP3CfIO7BhKJC+4p7L6a1+YsRR/c3CEcFH++NsOKdcmFbzpzpH3skNe
# X+71Vn0VNXmgrSje/x26Wo+FKzra50FA57QXtBB3rz/0mtZaLWuqkoG/tSuBjNvV
# J2yCAajIuiS5Nooik8+76Ajw4PQSkIe/s9xOzHc6gvxekQtLYV6fJQ/f15VuPSZ1
# Gdo9310rzQWnB9xiZe2BR1ylzq/5/aM/1HmU+zXwyEFthy2wFkGXJK8u4JC7vmcH
# Rp7pyhhwyWn56UHZANllz08OpeR13yvWQZeaJwp0TOLgHglth+XDuULMv8vkR98c
# ge7YAkIOLVFeiLUKjYGT1wIDAQABo4ICAjCCAf4wHwYDVR0jBBgwFoAUaDfg67Y7
# +F8Rhvv+YXsIiGX0TkIwHQYDVR0OBBYEFOdeboNElsywAuHpL+DqJa6ik83MMD0G
# A1UdIAQ2MDQwMgYFZ4EMAQMwKTAnBggrBgEFBQcCARYbaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vQ1BTMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzCBtQYDVR0fBIGtMIGqMFOgUaBPhk1odHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRUcnVzdGVkRzRDb2RlU2lnbmluZ1JTQTQwOTZTSEEzODQyMDIxQ0Ex
# LmNybDBToFGgT4ZNaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1
# c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcmwwgZQGCCsG
# AQUFBwEBBIGHMIGEMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5j
# b20wXAYIKwYBBQUHMAKGUGh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdp
# Q2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEuY3J0
# MAkGA1UdEwQCMAAwDQYJKoZIhvcNAQELBQADggIBAM8Sju/eIoI6/OS+2VcTmBjQ
# CJsjEtyjxGAWS7OQm1XuJqOyR4XZIFbi9UE5A0zDAuH4pwD8fYpEfn3terhffRHz
# /HA/cMSu92C4OJAf/AUO20BMo7fRnWh1F+wTUv+K1bCWHZS245m03NE+UqlvTNu8
# LzvvXBTtEckQdB2XlY39MdWDYxJFINL6bQT7vtGdBvZqDGAeyTaVlvSxHkvDVDtQ
# r2K1y3aaZyz91Ek+eTyeCxb0dUkEsntT066cqd1DuvDg5o6qsCJXS/CEfV5u27py
# 5XV3GMeRSw9iAK8eujrfCoztRUia+ZLZoZ/5isqRmokeynNi+KY/VSe2jMIqoJ3J
# yNsEZFJAPF0M6hDcAjzETOSA1ZcvR6npB1jaUDPWKIld7s8gpWV/8jM+61Kh3Sj0
# I1O2JZCxpLegx1dDSCkmUufK6Io3FH1zjQtddQnlAFwW+3IPfyoP0YKlIyenlF0h
# fuBxOlaJ8LZ7VLFcNWzGjhOdwOV/t+JnxVJPFx1RXR3Q8NmmMe08afq22TLpkXQL
# KwXuKtSi3h1cmOFPtnEqABB5VLUPYZlINCgNFWSY+gKCULWJKkQhpVN5r1yO3LbT
# tDRvoQRwPoNs9CkNVl9HQ+Qv6sbpqAqLfGEeN+SEv7lo9lUsUKxAaw1yaVBHIISI
# anBZbb3T3Kf7DmGQDth6MYIZ6jCCGeYCAQEwfTBpMQswCQYDVQQGEwJVUzEXMBUG
# A1UEChMORGlnaUNlcnQsIEluYy4xQTA/BgNVBAMTOERpZ2lDZXJ0IFRydXN0ZWQg
# RzQgQ29kZSBTaWduaW5nIFJTQTQwOTYgU0hBMzg0IDIwMjEgQ0ExAhAOeHFNrWpQ
# adD+X7fviblJMA0GCWCGSAFlAwQCAQUAoIGEMBgGCisGAQQBgjcCAQwxCjAIoAKA
# AKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIN9tDHpgqbYtUTODfB+e0McY
# LqABivvpapsZy6I/QgJOMA0GCSqGSIb3DQEBAQUABIICAB1OyGAZBlCCndd9nhb/
# fyspeVGuDYLXxPTgv50ayCWfI3yVd6a6EMeGmgA7TgDpjJRSKvrJP+GWz7iFUySA
# Jg1eJuMe+8WNWmwraYwoXNn89VJhQEZD7+jikYyKsVWMGr3Me0llOc35Mi1p2Rt4
# u/nNt4XeldQDeQ/Cr6hxQ1qGIVS3O6D8xTpH/jxMczIG6o5xYOQilH/Y3J6j35SO
# 201eMXqkY8xUjLOD5fnclDQg4+L8qG3B9Rcp7NCYzlVK+ix3f8p6UxOx0i6zpUNl
# zAmp3dnb0tOPlH/NYJGDu43uxa5YyvWjZacaLn6saAfojxt1jRJX5rLJt0FuEiCz
# vvoTHpMW3JCzRbYkW8+VBoazatnrHQHPGcfbEvz2WpAuF8XIw7dmnn7nwbnP0Dci
# F24JblAqn9zTs2n5tAmhwbT5YKvvACiU2QKyWhxVQls+PLMSnVPw04z2h19Z5Nm6
# duhYeC6Q5VKZdOdFrT6e8wCo9frqU+oIlRpT3iIgodwQ+E/dorKz9lrxzef94069
# KT5DI22crlWSOCPBcZLVke1KwJ1+lP94YBF+qzCHECGKsgjbBAlLoLCoqlcCAjpt
# SNSUJrh2AEMtbsQ2vgCNmiL0aAQ942UYjPwrG7+A2bJ9un9z7LyZlvG1kM9cVCtI
# ASfy3u1IDTdIZNEFl4NFqbqroYIWtzCCFrMGCisGAQQBgjcDAwExghajMIIWnwYJ
# KoZIhvcNAQcCoIIWkDCCFowCAQMxDTALBglghkgBZQMEAgEwgdwGCyqGSIb3DQEJ
# EAEEoIHMBIHJMIHGAgEBBgkrBgEEAaAyAgMwMTANBglghkgBZQMEAgEFAAQgk3k1
# QlY3LNp57WcZSxLJlgpPemYmT42iE2Bjv2kqlgoCFD+/K0F0Iz4egJ9hJiojFtxa
# bAKYGA8yMDI1MDYxMjE0MTg0OVowAwIBAaBXpFUwUzELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoMEEdsb2JhbFNpZ24gbnYtc2ExKTAnBgNVBAMMIEdsb2JhbHNpZ24gVFNB
# IGZvciBBZHZhbmNlZCAtIEc0oIISSjCCBmIwggRKoAMCAQICEAEDMuFlv5t4Q+CZ
# dZRjdwswDQYJKoZIhvcNAQEMBQAwWzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEds
# b2JhbFNpZ24gbnYtc2ExMTAvBgNVBAMTKEdsb2JhbFNpZ24gVGltZXN0YW1waW5n
# IENBIC0gU0hBMzg0IC0gRzQwHhcNMjUwNDExMTQ0NzAxWhcNMzQxMjEwMDAwMDAw
# WjBTMQswCQYDVQQGEwJCRTEZMBcGA1UECgwQR2xvYmFsU2lnbiBudi1zYTEpMCcG
# A1UEAwwgR2xvYmFsc2lnbiBUU0EgZm9yIEFkdmFuY2VkIC0gRzQwggGiMA0GCSqG
# SIb3DQEBAQUAA4IBjwAwggGKAoIBgQC+JXo5QxiuddbVs6HIm9Ymnp6AFjdZrvTn
# J4O4KsPMxDqvLLcu68jav8MFr3ls1zYS2rYzXjENJ/PhPQOBG7M77kRoJp4z5Mj1
# JiUv4JDZA0f0JmVdQcS8rAkBIT3sGSBGL0AfbGW91TNlveIgpETFWnAjLUSqtkbK
# gHnqPL47bMhpuDIKV0jiCQRzOq+BcygWcvkbE7c49EY4N+npJSP57DC2giCg/hO3
# YApe+2L4b4W8fBs3r3ZP72NR/BEAlwWWuiTbX0eg2iw8LIfIMU3MyObEXSN8pmKT
# aL/MplcAc7p9yluDLJNATCJ9uX3Mb2+dNYSCHyqZ1wGRCs2j0Bgw8ZZMezzXVM18
# PnhenlcyWHk6C0Vzmpjh2K0l/vjC9Ajrz6trIPxnl5Ry9XjG/1IYyilNK8bYoNbI
# wzB7MBqEGEn0tszc1tTaHh0RQoEvzrCelYFi3JcxSBaRk8wK2YipbvGWm2/lyDvJ
# QD8fXUFP+gAtDE6VcRvVSawwkMtKGE8CAwEAAaOCAagwggGkMA4GA1UdDwEB/wQE
# AwIHgDAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAdBgNVHQ4EFgQU2Te2M0VujzUH
# zvepswr9oKnI+YIwVgYDVR0gBE8wTTAIBgZngQwBBAIwQQYJKwYBBAGgMgEeMDQw
# MgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRv
# cnkvMAwGA1UdEwEB/wQCMAAwgZAGCCsGAQUFBwEBBIGDMIGAMDkGCCsGAQUFBzAB
# hi1odHRwOi8vb2NzcC5nbG9iYWxzaWduLmNvbS9jYS9nc3RzYWNhc2hhMzg0ZzQw
# QwYIKwYBBQUHMAKGN2h0dHA6Ly9zZWN1cmUuZ2xvYmFsc2lnbi5jb20vY2FjZXJ0
# L2dzdHNhY2FzaGEzODRnNC5jcnQwHwYDVR0jBBgwFoAU6hbGaefjy1dFOTOk8EC+
# 0MO9ZZYwQQYDVR0fBDowODA2oDSgMoYwaHR0cDovL2NybC5nbG9iYWxzaWduLmNv
# bS9jYS9nc3RzYWNhc2hhMzg0ZzQuY3JsMA0GCSqGSIb3DQEBDAUAA4ICAQBmH88E
# YcQnDDBjnRcpWHsx9D3GkugAavxN8Xn4ZyxS8YdPVDHm9oBP1zw7gQ2jkdQKy3pa
# bMFSC0L5KQbMM34XmmdI/8PnI6vxNNyJ+xw/PBfVkZ+9jcaJEgVTDnaRBqslnWcn
# iHL9Q29hKa5m9ryMIrjDXrOf368ag0X9sO9uFF9Oy7pi2FUTQ7R+HSJe6pasn3fn
# J93urP7ljSRjshdGJPVN8Oom5AFZqPVtiakjEcnEPHAu7LxP5LqtxoM7HEjmaKs5
# 9zCmpDSw41abvc+xod+ka7pQq6lRXb2QwIISzxYlxsVXPuycrJVahcm2wjpM1LzB
# NPG73ccEYyDAwYD0kkBq4RrCkRnc5/TD91SfUKRwrgK9vb95+LRknaOzedxzPtFg
# WIJnrIisxmo8u/f+KUTn5GpkEMzPonq4LYGtHDWqvYSvJ6W6woQdDUgPqgaU8YIH
# 9JnM5VL3mRfiBeiFuPjScQW9v6VBX8n0qoNz0fhtw/oE0pAIP3XEtA5OX9CY6tLq
# pE4wOMNC96neBY2TXdLDbQEwiCFk+xTep7DEjQbVkj115kd1PfAHxtP+de/0gcYg
# oALzlsdIZg0wnaVCX0d72pNjsQZWUUMX7nQIPNBsvFydseV5W03AWsgB4Q9o7Zvd
# RXRIJRRcUjNOZkvwCXgxMNvS1WU5UbBgTGMekDCCBlkwggRBoAMCAQICDQHsHJJA
# 3v0uQF18R3QwDQYJKoZIhvcNAQEMBQAwTDEgMB4GA1UECxMXR2xvYmFsU2lnbiBS
# b290IENBIC0gUjYxEzARBgNVBAoTCkdsb2JhbFNpZ24xEzARBgNVBAMTCkdsb2Jh
# bFNpZ24wHhcNMTgwNjIwMDAwMDAwWhcNMzQxMjEwMDAwMDAwWjBbMQswCQYDVQQG
# EwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UEAxMoR2xvYmFs
# U2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAPAC4jAj+uAb4Zp0s691g1+pR1LHYTpjfDkjeW10
# /DHkdBIZlvrOJ2JbrgeKJ+5Xo8Q17bM0x6zDDOuAZm3RKErBLLu5cPJyroz3mVpd
# dq6/RKh8QSSOj7rFT/82QaunLf14TkOI/pMZF9nuMc+8ijtuasSI8O6X9tzzGKBL
# mRwOh6cm4YjJoOWZ4p70nEw/XVvstu/SZc9FC1Q9sVRTB4uZbrhUmYqoMZI78np9
# /A5Y34Fq4bBsHmWCKtQhx5T+QpY78Quxf39GmA6HPXpl69FWqS69+1g9tYX6U5lN
# W3TtckuiDYI3GQzQq+pawe8P1Zm5P/RPNfGcD9M3E1LZJTTtlu/4Z+oIvo9Jev+Q
# sdT3KRXX+Q1d1odDHnTEcCi0gHu9Kpu7hOEOrG8NubX2bVb+ih0JPiQOZybH/LIN
# oJSwspTMe+Zn/qZYstTYQRLBVf1ukcW7sUwIS57UQgZvGxjVNupkrs799QXm4mbQ
# DgUhrLERBiMZ5PsFNETqCK6dSWcRi4LlrVqGp2b9MwMB3pkl+XFu6ZxdAkxgPM8C
# jwH9cu6S8acS3kISTeypJuV3AqwOVwwJ0WGeJoj8yLJN22TwRZ+6wT9Uo9h2ApVs
# ao3KIlz2DATjKfpLsBzTN3SE2R1mqzRzjx59fF6W1j0ZsJfqjFCRba9Xhn4QNx1r
# GhTfAgMBAAGjggEpMIIBJTAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB
# /wIBADAdBgNVHQ4EFgQU6hbGaefjy1dFOTOk8EC+0MO9ZZYwHwYDVR0jBBgwFoAU
# rmwFo5MT4qLn4tcc1sfwf8hnU6AwPgYIKwYBBQUHAQEEMjAwMC4GCCsGAQUFBzAB
# hiJodHRwOi8vb2NzcDIuZ2xvYmFsc2lnbi5jb20vcm9vdHI2MDYGA1UdHwQvMC0w
# K6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2lnbi5jb20vcm9vdC1yNi5jcmwwRwYD
# VR0gBEAwPjA8BgRVHSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2Jh
# bHNpZ24uY29tL3JlcG9zaXRvcnkvMA0GCSqGSIb3DQEBDAUAA4ICAQB/4ojZV2cr
# Ql+BpwkLusS7KBhW1ky/2xsHcMb7CwmtADpgMx85xhZrGUBJJQge5Jv31qQNjx6W
# 8oaiF95Bv0/hvKvN7sAjjMaF/ksVJPkYROwfwqSs0LLP7MJWZR29f/begsi3n2HT
# tUZImJcCZ3oWlUrbYsbQswLMNEhFVd3s6UqfXhTtchBxdnDSD5bz6jdXlJEYr9yN
# mTgZWMKpoX6ibhUm6rT5fyrn50hkaS/SmqFy9vckS3RafXKGNbMCVx+LnPy7rEze
# +t5TTIP9ErG2SVVPdZ2sb0rILmq5yojDEjBOsghzn16h1pnO6X1LlizMFmsYzeRZ
# N4YJLOJF1rLNboJ1pdqNHrdbL4guPX3x8pEwBZzOe3ygxayvUQbwEccdMMVRVmDo
# fJU9IuPVCiRTJ5eA+kiJJyx54jzlmx7jqoSCiT7ASvUh/mIQ7R0w/PbM6kgnfIt1
# Qn9ry/Ola5UfBFg0ContglDk0Xuoyea+SKorVdmNtyUgDhtRoNRjqoPqbHJhSsn6
# Q8TGV8Wdtjywi7C5HDHvve8U2BRAbCAdwi3oC8aNbYy2ce1SIf4+9p+fORqurNIv
# eiCx9KyqHeItFJ36lmodxjzK89kcv1NNpEdZfJXEQ0H5JeIsEH6B+Q2Up33ytQn1
# 2GByQFCVINRDRL76oJXnIFm2eMakaqoimzCCBYMwggNroAMCAQICDkXmuwODM8OF
# ZUjm/0VRMA0GCSqGSIb3DQEBDAUAMEwxIDAeBgNVBAsTF0dsb2JhbFNpZ24gUm9v
# dCBDQSAtIFI2MRMwEQYDVQQKEwpHbG9iYWxTaWduMRMwEQYDVQQDEwpHbG9iYWxT
# aWduMB4XDTE0MTIxMDAwMDAwMFoXDTM0MTIxMDAwMDAwMFowTDEgMB4GA1UECxMX
# R2xvYmFsU2lnbiBSb290IENBIC0gUjYxEzARBgNVBAoTCkdsb2JhbFNpZ24xEzAR
# BgNVBAMTCkdsb2JhbFNpZ24wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQCVB+hzymb57BTKezz3DQjxtEULLIK0SMbrWzyug7hBkjMUpG9/6SrMxrCIa8W2
# idHGsv8UzlEUIexK3RtaxtaH7k06FQbtZGYLkoDKRN5zlE7zp4l/T3hjCMgSUG1C
# Zi9NuXkoTVIaihqAtxmBDn7EirxkTCEcQ2jXPTyKxbJm1ZCatzEGxb7ibTIGph75
# ueuqo7i/voJjUNDwGInf5A959eqiHyrScC5757yTu21T4kh8jBAHOP9msndhfuDq
# jDyqtKT285VKEgdt/Yyyic/QoGF3yFh0sNQjOvddOsqi250J3l1ELZDxgc1Xkvp+
# vFAEYzTfa5MYvms2sjnkrCQ2t/DvthwTV5O23rL44oW3c6K4NapF8uCdNqFvVIrx
# clZuLojFUUJEFZTuo8U4lptOTloLR/MGNkl3MLxxN+Wm7CEIdfzmYRY/d9XZkZeE
# CmzUAk10wBTt/Tn7g/JeFKEEsAvp/u6P4W4LsgizYWYJarEGOmWWWcDwNf3J2iiN
# GhGHcIEKqJp1HZ46hgUAntuA1iX53AWeJ1lMdjlb6vmlodiDD9H/3zAR+YXPM0j1
# ym1kFCx6WE/TSwhJxZVkGmMOeT31s4zKWK2cQkV5bg6HGVxUsWW2v4yb3BPpDW+4
# LtxnbsmLEbWEFIoAGXCDeZGXkdQaJ783HjIH2BRjPChMrwIDAQABo2MwYTAOBgNV
# HQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUrmwFo5MT4qLn
# 4tcc1sfwf8hnU6AwHwYDVR0jBBgwFoAUrmwFo5MT4qLn4tcc1sfwf8hnU6AwDQYJ
# KoZIhvcNAQEMBQADggIBAIMl7ejR/ZVSzZ7ABKCRaeZc0ITe3K2iT+hHeNZlmKlb
# qDyHfAKK0W63FnPmX8BUmNV0vsHN4hGRrSMYPd3hckSWtJVewHuOmXgWQxNWV7Oi
# szu1d9xAcqyj65s1PrEIIaHnxEM3eTK+teecLEy8QymZjjDTrCHg4x362AczdlQA
# Iiq5TSAucGja5VP8g1zTnfL/RAxEZvLS471GABptArolXY2hMVHdVEYcTduZlu8a
# HARcphXveOB5/l3bPqpMVf2aFalv4ab733Aw6cPuQkbtwpMFifp9Y3s/0HGBfADo
# mK4OeDTDJfuvCp8ga907E48SjOJBGkh6c6B3ace2XH+CyB7+WBsoK6hsrV5twAXS
# e7frgP4lN/4Cm2isQl3D7vXM3PBQddI2aZzmewTfbgZptt4KCUhZh+t7FGB6ZKpp
# Q++Rx0zsGN1s71MtjJnhXvJyPs9UyL1n7KQPTEX/07kwIwdMjxC/hpbZmVq0mVcc
# pMy7FYlTuiwFD+TEnhmxGDTVTJ267fcfrySVBHioA7vugeXaX3yLSqGQdCWnsz5L
# yCxWvcfI7zjiXJLwefechLp0LWEBIH5+0fJPB1lfiy1DUutGDJTh9WZHeXfVVFsf
# rSQ3y0VaTqBESMjYsJnFFYQJ9tZJScBluOYacW6gqPGC6EU+bNYC1wpngwVayaQQ
# MYIDSTCCA0UCAQEwbzBbMQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2ln
# biBudi1zYTExMC8GA1UEAxMoR2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBT
# SEEzODQgLSBHNAIQAQMy4WW/m3hD4Jl1lGN3CzALBglghkgBZQMEAgGgggEtMBoG
# CSqGSIb3DQEJAzENBgsqhkiG9w0BCRABBDArBgkqhkiG9w0BCTQxHjAcMAsGCWCG
# SAFlAwQCAaENBgkqhkiG9w0BAQsFADAvBgkqhkiG9w0BCQQxIgQgmUHqm7AiGHzA
# ej4OAFK4HRdxK4o3hntlC1hdi+dZ8ywwgbAGCyqGSIb3DQEJEAIvMYGgMIGdMIGa
# MIGXBCCRkkebYjW5dia/tgFteAiRg3ID2HORwGwbjj13/+LHNzBzMF+kXTBbMQsw
# CQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTExMC8GA1UEAxMo
# R2xvYmFsU2lnbiBUaW1lc3RhbXBpbmcgQ0EgLSBTSEEzODQgLSBHNAIQAQMy4WW/
# m3hD4Jl1lGN3CzANBgkqhkiG9w0BAQsFAASCAYChoS8IOSPdHCXLaxx6jm+BZFcj
# gqSw/AEeWD+yfUS5oy2dek6iKzxv3LDBERrlZrt8qJYe6+jLt1ebn92yUL/+tYrB
# GXpi7Xd8TkGJGeYt1GmnU9uGl0j0+AFyAhAMJF9XSUZsMvU2M3el3Up85oZywo3e
# OEhquUnKwVtsobvH3VP94mnHcOm5bGWydgNhkjc1NGJYJYyIAaDHsvurqHWnNKTN
# dMijsNr1UedLhGMKiXVvAOGfg/e0OrtZUsxUp+FnhX3q+CFTKwRQWwtk6KLDvdTD
# ojb+N0kSuR/zJSGKrqGes5v/ibLLYb6vok8SYXhA5J/aYdFywIHKfZMOrO9xe47w
# T2SJI/PVe76XJiOfGQk+5FpIZ6f6vD3t/1BHiG7TkSOz+nplVY04qJJyVIPhm6Er
# FzT+rK2MCVxQ4lbxpaqepJFP88SlqbHAxR4AilQqCwUzKsiSFiG/ArBIJtaQdwOB
# 69/+C8GnB0J0weEMq82ZgH2VPEH27Mbh1JQ116Y=
# SIG # End signature block
