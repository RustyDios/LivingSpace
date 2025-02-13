class UIAlert_LivingSpace extends UIAlert;

var localized string strCrewOverflowTitle;
var localized string strCrewOverflowHeader;
var localized string strCrewOverflowDescription;
var localized string strCrewOverflowNoWorkshop;
var localized string strCrewOverflowNoLaboratory;
var localized string strCrewOverflowNeitherFacility;

simulated function BuildAlert ()
{
	BindLibraryItem();

	switch (eAlertName)
	{
		case 'eAlert_CrewOverflow':
			BuildCrewOverflow();
		break;
				
		default:
			AddBG(MakeRect(0, 0, 1000, 500), eUIState_Normal).SetAlpha(0.75f);
		break;
	}

	// Set up the navigation *after* the alert is built, so that the button visibility can be used. 
	RefreshNavigation();
}

simulated function name GetLibraryID ()
{
	switch (eAlertName)
	{
		case 'eAlert_CrewOverflow':	return 'Alert_Warning';
		
		default:
			return '';
	}
}

simulated function PresentUIEffects ()
{
	super.PresentUIEffects();

	if (eAlertName == 'eAlert_CrewOverflow')
	{
		CrewOverflowShowLivingRoom();
	}
}

simulated protected function BuildCrewOverflow ()
{
	local TAlertHelpInfo Info;

	Info.strTitle = strCrewOverflowTitle;
	Info.strHeader = strCrewOverflowHeader;
	Info.strDescription = GetCrewOverflowDescription();
	Info.strImage = "img:///UILibrary_XPACK_StrategyImages.Alert_Avenger_Attacked";
	Info.strConfirm = m_strOK;

	BuildHelpAlert(Info);
}

simulated protected function CrewOverflowShowLivingRoom ()
{
	`HQPRES.CAMLookAtRoom(`XCOMHQ.GetRoom(16), bInstantInterp ? float(0) : `HQINTERPTIME);
}

simulated protected function string GetCrewOverflowDescription ()
{
	local string Description, SciFacilities, EngFacilities;
	local XGParamTag ParamTag;

	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));

	SciFacilities = FormulateFacilityString(class'LSHelpers'.default.FACILITY_HOLDS_SCIENTIST);
	EngFacilities = FormulateFacilityString(class'LSHelpers'.default.FACILITY_HOLDS_ENGINEER);

	ParamTag.StrValue0 = EngFacilities;
	ParamTag.StrValue1 = SciFacilities;

	Description = strCrewOverflowDescription;
	
	if (!class'LSHelpers'.static.CheckForFacilityNamesListed(class'LSHelpers'.default.FACILITY_HOLDS_SCIENTIST)
	 && !class'LSHelpers'.static.CheckForFacilityNamesListed(class'LSHelpers'.default.FACILITY_HOLDS_ENGINEER))
	{
		Description = Description $ "\n\n" $ strCrewOverflowNeitherFacility;
	}
	else if (!class'LSHelpers'.static.CheckForFacilityNamesListed(class'LSHelpers'.default.FACILITY_HOLDS_SCIENTIST))
	{
		Description = Description $ "\n\n" $ strCrewOverflowNoLaboratory;
	}
	else if (!class'LSHelpers'.static.CheckForFacilityNamesListed(class'LSHelpers'.default.FACILITY_HOLDS_ENGINEER))
	{
		Description = Description $ "\n\n" $ strCrewOverflowNoWorkshop;
	}

	return `XEXPAND.ExpandString(Description);
}

static function string FormulateFacilityString(array<name> ListOfFacilityNames)
{
	local string FacilitiesListed;
	local int i;

	FacilitiesListed = "-- ";

	for (i = 0 ; i < ListOfFacilityNames.length ; i++)
	{
		FacilitiesListed $= GetFacilityName(ListOfFacilityNames[i]);

		if (i < ListOfFacilityNames.length-1)
		{
			FacilitiesListed $=", ";
		}
	}

	return FacilitiesListed;
}

static function string GetFacilityName (name FacilityName)
{
	local X2FacilityTemplate FacilityTemplate;

	FacilityTemplate = X2FacilityTemplate(class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager().FindStrategyElementTemplate(FacilityName));

	return FacilityTemplate.DisplayName;
}
