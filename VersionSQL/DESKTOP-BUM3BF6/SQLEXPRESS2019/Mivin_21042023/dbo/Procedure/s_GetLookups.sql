/****** Object:  Procedure [dbo].[s_GetLookups]    Committed by VersionSQL https://www.versionsql.com ******/

/********************************************
ER0346:: Created on : 8th Jan 2013 By Geetanjali Kore :: Lookup for master tables
s_GetLookups 'opn','CNC-15','','LA25BWD03-LKD'
S_GetLookUps 'Machine','CNC SHOP1','asc','','SIEMENS'
*******************************************/
CREATE procedure [dbo].[s_GetLookups]
 @name nvarchar(50),--Plant,Machine,AlarmCategory,PredefinedTimePeriod,Comp,operation
 @filter nvarchar(100)='',
 @order varchar(5)='asc',
 @filter1 nvarchar(50)='',
 @ControllerType nvarchar(50)=''
as
begin
declare @strsql nvarchar(4000)
Create table #shift (shiftname nvarchar(50))

if @name='Plant' 
begin
	set @strsql=''
	set   @strsql='Select distinct pm.Plantid from plantmachine pm inner join machineinformation mi
	on   pm.machineid=mi.machineid and  tpmtrakenabled=1 order by pm.plantid '
	set @strsql= @strsql + @order
	exec(@strsql)
end

if @name='Machine' and @filter=''
begin
	set @strsql=''
	set @strsql='select Machineid from machineinformation where tpmtrakenabled=1 order by machineid '
	set @strsql= @strsql + @order
	exec(@strsql)
end

if @name='Machine' and @filter<>''
begin
	--set @strsql=''
	--set   @strsql='Select mi.Machineid from plantmachine pm inner join machineinformation mi
	--on   pm.machineid=mi.machineid and  tpmtrakenabled=1 and pm.plantid='
	--set @strsql= @strsql +''''+@filter+''''
	--set @strsql= @strsql+' order by mi.machineid '
	--set @strsql= @strsql + @order
	--exec(@strsql)
	if(@order = 'asc')
	BEGIN
	select mi.Machineid from plantmachine pm inner join machineinformation mi on pm.Machineid = mi.Machineid and 
	TpmTrakEnabled=1 and (pm.plantid=@filter or @filter='') and (mi.ControllerType = @ControllerType or @ControllerType = '')
	order by mi.Machineid asc
	END
	else
	BEGIN
	select mi.Machineid from plantmachine pm inner join machineinformation mi on pm.Machineid = mi.Machineid and 
	TpmTrakEnabled=1 and (pm.plantid=@filter or @filter='') and (mi.ControllerType = @ControllerType or @ControllerType = '')
	order by mi.Machineid desc
	END

end

if @name='AlarmCategory'
begin
	set @strsql=''
	set   @strsql='select Alarmno from  preventivemaster where charindex (''.'',alarmno)=''0'' order by alarmno '
	set @strsql= @strsql + @order
	exec(@strsql)
end

if @name='PredefinedTimePeriod'
begin
	INSERT INTO #shift (shiftname)
	Select 'Today - ' +shiftname  as shiftname from shiftdetails  where running=1 
	UNION ALL
	Select 'Today - All' 
	UNION ALL
	Select 'Yesterday - ' +shiftname  as shiftname from shiftdetails  where running=1 
	UNION ALL
	Select 'Yesterday - All' 
	Select * from #shift
end


if @name='Comp' and @filter=''
begin
	set @strsql=''
	set   @strsql='select distinct C.Componentid from componentoperationpricing C inner join Machineinformation M on M.machineid=C.machineid  inner join PlantMachine P on P.MachineID=M.Machineid where M.tpmtrakenabled=1 '
	set @strsql= @strsql+' order by C.Componentid '
	set @strsql= @strsql + @order
	exec(@strsql)
end

if @name='Comp' and @filter<>''
begin
	set @strsql=''
	set  @strsql='select distinct C.Componentid from componentoperationpricing C inner join Machineinformation M on M.machineid=C.machineid inner join PlantMachine P on P.MachineID=M.Machineid  where M.tpmtrakenabled=1 and M.Machineid='
	set @strsql= @strsql +''''+@filter+''''
	set @strsql= @strsql+' order by C.Componentid '
	set @strsql= @strsql + @order
	exec(@strsql)
end

if @name='Opn' 
begin

    select  distinct Operationno from componentoperationpricing COP 
	inner join  Componentinformation CI on COP.componentid=CI.componentid  
	inner join machineinformation m on COP.machineid=M.machineid
	where  (COP.machineid= @filter or @filter = '' )and  (COP.componentid= @filter1 or @filter1 = '')

	--set @strsql=''
	--set   @strsql='select  distinct Operationno from componentoperationpricing COP inner join  Componentinformation CI on COP.componentid=CI.componentid  inner join machineinformation m on COP.machineid=M.machineid'
	--set @strsql= @strsql+' order by COP.Operationno '
	--set @strsql= @strsql + @order
	--exec(@strsql)
end

if @name='Opn' and @filter<>'' and @filter1<>''
begin
	set @strsql=''
	set   @strsql='select  distinct Operationno from componentoperationpricing COP inner join  Componentinformation CI on COP.componentid=CI.componentid  inner join machineinformation m on COP.machineid=M.machineid '
	set @strsql= @strsql +' where COP.machineid='''+@filter+''''
	set @strsql= @strsql +'and COP.componentid= '''+@filter1+''''
	set @strsql= @strsql+' order by COP.Operationno '
	set @strsql= @strsql + @order
	exec(@strsql)
end

End
