---
layout:post
title: $i
tags: ["howto"]
---




- in vs6.0, new project... 
    -- select "ATL COM AppWizard" project... 
    -- select DLL... 
    -- select "Allow merging of proxy-stub code"
- insert "New ATL Object"... 
    -- simple object.... 
    -- Named "Addin"
    -- under Attributes, support ISupportErrorInfo
- right-click on class CAddIn and Implement interface
    -- import new type library... "Microsoft Addin..."
    -- let CAddIn implement _IDTExtensibility2
- edit Addin.rgs
    -- add the following to the bottom:
------------------8<-----------------
HKCU
{
	Software
	{
		Microsoft
		{
			Office
			{
				Excel
				{
					Addins
					{
						'projectName.Addin'
						{
							val FriendlyName = s 'projectName Addin'
							val Description = s 'project description'
							val LoadBehavior = d '00000008'
							val CommandLineSafe = d '00000000'
						}
					}
				}
			}
		}
	}
}
------------------8<-----------------

- edit stdafx.h.... add
------------------8<-----------------
// for OfficeXP
//#import "C:\\Program Files\\Common Files\\Microsoft Shared\\Office10\\MSO.DLL" 
#import "C:\\Program Files\\Microsoft Office\\Office\\mso9.dll" rename_namespace("Office2000")
using namespace Office2000;

#import "C:\\Program Files\\Common Files\\Microsoft Shared\\VBA\\VBA6\\VBE6EXT.olb" rename_namespace("VBE6")
//using namespace VBE6;
------------------8<-----------------


- edit Addin.h.... add
------------------8<-----------------
#import "C:\\Program Files\\Microsoft Office\\Office\\excel9.olb" rename_namespace("Excel") rename("IAddIn", "IAddInXL") rename("DialogBox", "DialogBoxXL") rename("RGB", "RBGXL") rename("DocumentProperties", "DocumentPropertiesXL") raw_interfaces_only named_guids
using namespace Excel;
------------------8<-----------------

- implement OnConnect and OnDisconnect from IDTExtensibility2
- set up sink maps for menu events... 
- make sure you extend CAddin from
	public IDispEventSimpleImpl<1,CAddin,&__uuidof(Office2000::_CommandBarButtonEvents)>
- place at the top of Addin.h:
extern _ATL_FUNC_INFO OnClickButtonInfo;
- place at the top of Addin.cpp:
_ATL_FUNC_INFO OnClickButtonInfo = {CC_STDCALL,VT_EMPTY,2,{VT_DISPATCH,VT_BYREF | VT_BOOL}};
- add to CAddin:
------------------8<-----------------
	void __stdcall OnClickButton(IDispatch* /*Office2000::CommandBarButton*/ Ctrl,
				    			 VARIANT_BOOL* CancelDefault);
	BEGIN_SINK_MAP(CAddin)
		SINK_ENTRY_INFO(1,
						__uuidof(Office2000::_CommandBarButtonEvents),
						/*dispid*/ 0x01,
						OnClickButton,
						&OnClickButtonInfo)
	END_SINK_MAP()
private:
	CComPtr<MSExcel::_Application> m_spApp;
	CComPtr<Office2000::_CommandBarButton> m_spButton;

------------------8<-----------------
-add to Addin.cpp
------------------8<-----------------
STDMETHODIMP CAddin::OnConnection(IDispatch * Application, 
								  ext_ConnectMode ConnectMode, 
								  IDispatch * AddInInst, 
								  SAFEARRAY * * custom)
{

	CComQIPtr<MSExcel::_Application> spApp(Application);
	ATLASSERT(spApp);
	m_spApp = spApp;

	CComPtr<Office2000::_CommandBars> spCommandBars;
	HRESULT hr = m_spApp->get_CommandBars(&spCommandBars);
	if ( FAILED(hr) ) {
		return hr;
	}
	ATLASSERT(spCommandBars);

	CComPtr<Office2000::CommandBar> mainMenu;
	hr = spCommandBars->get_ActiveMenuBar(&mainMenu);
	if ( FAILED(hr) ) {
		return hr;
	}
	
	CComPtr<Office2000::CommandBarControls> mainMenuControls = mainMenu->GetControls();
	ATLASSERT(mainMenuControls);

	CComVariant vType(10);//Office2000::MsoControlType::msoControlPopup 
	CComVariant vEmpty(DISP_E_PARAMNOTFOUND, VT_ERROR);
	CComVariant vTemp(VARIANT_TRUE);
	CComVariant vBefore(2);
	CComPtr<Office2000::CommandBarControl> analystMenuControl = 
		mainMenuControls->Add( vType, vEmpty, vEmpty, vBefore, vTemp );
	ATLASSERT(analystMenuControl);

	CComQIPtr<Office2000::CommandBarPopup> analystMenuPopup(analystMenuControl);
	ATLASSERT(analystMenuPopup);

	analystMenuPopup->PutCaption(OLESTR("Analyst"));
	analystMenuPopup->PutVisible(VARIANT_TRUE);

	CComPtr<Office2000::CommandBarControls> analystMenuControls = analystMenuPopup->GetControls();
	
	vType = 1;// Office2000::MsoControlType::msoControlButton
	CComPtr<Office2000::CommandBarControl> bindMenuItem = 
		analystMenuControls->Add( vType, vEmpty, vEmpty, vEmpty, vTemp );
	ATLASSERT(bindMenuItem);

	CComQIPtr<Office2000::_CommandBarButton> bindMenuButton(bindMenuItem);
	ATLASSERT(bindMenuButton);

	bindMenuButton->PutCaption(OLESTR("Bind Data"));
	bindMenuButton->PutFaceId(4);//?
	bindMenuButton->PutStyle(Office2000::msoButtonIconAndCaption);
	bindMenuButton->PutVisible(VARIANT_TRUE);

	m_spButton = bindMenuButton;

	DispEventAdvise((IDispatch*)m_spButton);

	return S_OK;
}

STDMETHODIMP CAddin::OnDisconnection(ext_DisconnectMode RemoveMode, SAFEARRAY * * custom)
{

	DispEventUnadvise((IDispatch*)m_spButton);

	return S_OK;
}


void __stdcall CAddin::OnClickButton(IDispatch* /*Office2000::CommandBarButton*/ Ctrl,
									 VARIANT_BOOL* CancelDefault)
{
	
	USES_CONVERSION;
	CComQIPtr<Office2000::_CommandBarButton> pCommandBarButton(Ctrl);

	CBindDataDialog bindDataDialog;
	bindDataDialog.DoModal();

	//MessageBox(NULL, "Clicked Button1", "OnClickButton", MB_OK);
	

}
------------------8<-----------------


