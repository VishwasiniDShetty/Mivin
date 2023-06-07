/****** Object:  Procedure [dbo].[Focas_GetSpindleProcessParameters]    Committed by VersionSQL https://www.versionsql.com ******/

--[dbo].[Focas_GetSpindleProcessParameters]'User defined','2066'
CREATE   PROCEDURE [dbo].[Focas_GetSpindleProcessParameters]      
@param nvarchar(50)=''  ,
@machineid nvarchar(50)=''     
AS      
BEGIN  

create table #temp
(
MacroVariable  nvarchar(100),
Description nvarchar(500),
Type nvarchar(50),
Value decimal(18,3),
Unit nvarchar(50),
UnitValue nvarchar(100)

)    

If @Param='User defined'
Begin

	insert into #temp(MacroVariable,Description,Type,Value,Unit)
	Select SP.MacroVariable,SP.Description ,SP.Type, SV.Value,SP.Unit
	From dbo.Focas_SpindleProcessParameters SP 
	inner join dbo.Focas_SpindleProcessValues SV on SP.MacroVariable=SV.MacroVariable
	where SV.Machineid=@Machineid and  SV.BatchTS=(Select Max(BatchTS) from dbo.Focas_SpindleProcessValues where Machineid=@Machineid and Type='User defined')
	AND SP.Type='User defined' Order by SP.MacroVariable


	update #temp set UnitValue =  Value;
	update #temp set UnitValue =  CEILING(Value)  where Unit in ('RPM','Number','','No.')
	update #temp set UnitValue= UnitValue ;
END

If @Param='output'
Begin

	insert into #temp(MacroVariable,Description,Type,Value,Unit)
	Select SP.MacroVariable,SP.Description ,SP.Type, SV.Value,SP.Unit
	From dbo.Focas_SpindleProcessParameters SP 
	inner join dbo.Focas_SpindleProcessValues SV on SP.MacroVariable=SV.MacroVariable
	where  SV.Machineid=@Machineid and  SV.BatchTS=(Select Max(BatchTS) from dbo.Focas_SpindleProcessValues where Machineid=@Machineid and Type='output')
	AND SP.Type='output' Order by SP.MacroVariable
	
	update #temp set UnitValue =  Value;
	update #temp set UnitValue =  CEILING(Value)  where Unit in ('RPM','Number','','No.')
	update #temp set UnitValue= UnitValue ;
	


END

select * from #temp;

      
End 
