# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# frozen_string_literal: true

require 'csv'

class AddPVT < OpenStudio::Measure::ModelMeasure

  def name
    return 'AddPVT'
  end

  def description
    return 'Testing codes'
  end

  def modeler_description
    return 'Testing codes for different idd object'
  end

  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    ## SolarCollector:FlatPlate:PhotovoltaicThermal

    # Name of the object
    obj_name = OpenStudio::Measure::OSArgument.makeStringArgument('obj_name', true)
    obj_name.setDisplayName('Uniquie Name for the PVT object')
    obj_name.setDefaultValue('Solar PhotoVoltaic Thermal Obj')
    args << obj_name
    
    # Surface name (dynamic choice argument)
    surfaces = model.getSurfaces
    surf_names = OpenStudio::StringVector.new
    surfaces.each do |surface|
      surf_names << surface.nameString
    end

    surf_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('surf_name', surf_names, true)
    surf_name.setDisplayName('Surface Name')
    args << surf_name

    # Working fluid type
    chs = OpenStudio::StringVector.new
    chs << "Water"
    chs << "Air"
    work_fluid = OpenStudio::Measure::OSArgument::makeChoiceArgument('work_fluid', chs, true)
    work_fluid.setDefaultValue("Air")
    work_fluid.setDisplayName('Working fluid type (Air or Water)')
    args << work_fluid

    # Name of the Plant Loop 
    plant_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('plant_loop_name', true)
    plant_loop_name.setDisplayName('Existing Plant Loop Name')
    plant_loop_name.setDefaultValue("HTR WTR Loop")
    args << plant_loop_name

    # Name of the AirLoop HVAC Outdoor Air
    air_loop_name = OpenStudio::Measure::OSArgument.makeStringArgument('air_loop_name', true)
    air_loop_name.setDisplayName('Existing AirLoop HVAC Outdoor Air Name')
    air_loop_name.setDefaultValue("Outdoor Air System")
    args << air_loop_name
    
    # Design flow rate
    design_flow_rate = OpenStudio::Measure::OSArgument.makeDoubleArgument('design_flow_rate', true)
    design_flow_rate.setDisplayName('Design flow rate (m3/s)')
    design_flow_rate.setDefaultValue(0.00005)
    args << design_flow_rate


    ## SolarCollectorPerformance:PhotovoltaicThermal:Simple

    # Name of the SolarCollectorPerformance object
    per_name = OpenStudio::Measure::OSArgument.makeStringArgument('per_name', true)
    per_name.setDisplayName('SolarCollectorPerformance:PhotovoltaicThermal Name')
    per_name.setDefaultValue("Performance Obj")
    args << per_name

    # set fraction_of_surface
    fract_of_surface = OpenStudio::Measure::OSArgument.makeDoubleArgument('fract_of_surface', true)
    fract_of_surface.setDisplayName('Fraction of Surface Area with Active Thermal Collector')
    fract_of_surface.setUnits('fraction')
    fract_of_surface.setDefaultValue(0.75)
    args << fract_of_surface

    # set thermal conversion efficiency
    chs = OpenStudio::StringVector.new
    chs << "Fixed"
    chs << "Scheduled"
    therm_eff = OpenStudio::Measure::OSArgument::makeChoiceArgument('therm_eff', chs, true)
    therm_eff.setDefaultValue("Fixed")
    therm_eff.setDisplayName('Thermal Conversion Eﬀiciency Input Mode Type')
    args << therm_eff

    # Value for Thermal Conversion Eﬀiciency if Fixed
    ther_eff_val = OpenStudio::Measure::OSArgument.makeDoubleArgument('ther_eff_val', false)
    ther_eff_val.setDisplayName('Thermal Conversion Eﬀiciency')
    ther_eff_val.setUnits('fraction')
    ther_eff_val.setDefaultValue(0.20)
    args << ther_eff_val

    # Name of Schedule for Thermal Conversion Eﬀiciency
    schedules = model.getSchedules
    schedule_names = OpenStudio::StringVector.new
    schedules.each do |schedule|
      schedule_names << schedule.nameString
    end

    schedule_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('schedule_name', schedule_names, false)
    schedule_name.setDisplayName('Schedule Name')
    args << schedule_name

    # Front Surface Emittance
    fron_surf_emittance = OpenStudio::Measure::OSArgument.makeDoubleArgument('fron_surf_emittance', true)
    fron_surf_emittance.setDisplayName('Front Surface Emittance')
    fron_surf_emittance.setUnits('fraction')
    fron_surf_emittance.setDefaultValue(0.90)
    args << fron_surf_emittance


    ## Generator:Photovoltaic
    # Photovoltaic Generator Name
    generator_name = OpenStudio::Measure::OSArgument.makeStringArgument('generator_name', true)
    generator_name.setDisplayName('Generator:Photovoltaic Name')
    generator_name.setDefaultValue('Generator Obj')
    args << generator_name

    # # Surface name for generator (dynamic choice argument)
    # gen_surf_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('gen_surf_name', surf_names, true)
    # gen_surf_name.setDisplayName('PV Generator Surface Name')
    # args << gen_surf_name

    
    ## PhotovoltaicPerformance:Simple

    # Fraction of surfaces to contain PV
    frac_surf_area_with_pv = OpenStudio::Measure::OSArgument.makeDoubleArgument('frac_surf_area_with_pv', true)
    frac_surf_area_with_pv.setDisplayName('Fraction of Included Surface Area with PV')
    frac_surf_area_with_pv.setDefaultValue(0.75)
    args << frac_surf_area_with_pv

    # #Conversion Eﬀiciency Input Mode
    chs1 = OpenStudio::StringVector.new
    chs1 << "Fixed"
    chs1 << "Scheduled"
    conversion_eff = OpenStudio::Measure::OSArgument::makeChoiceArgument('conversion_eff', chs1, true)
    conversion_eff.setDisplayName('Thermal Conversion Eﬀiciency Input Mode Type')
    conversion_eff.setDefaultValue("Fixed")
    args << conversion_eff

    # Value for Conversion Conversion Eﬀiciency if Fixed
    conversion_eff_val = OpenStudio::Measure::OSArgument.makeDoubleArgument('conversion_eff_val', false)
    conversion_eff_val.setDisplayName('Generator Conversion Eﬀiciency NB: Total efficiency of thermal and PV must be <=1')
    conversion_eff_val.setUnits('fraction')
    conversion_eff_val.setDefaultValue(0.3)
    args << conversion_eff_val

    # Name of Schedule for Conversion Eﬀiciency
    pv_schedule_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('pv_schedule_name', schedule_names, false)
    pv_schedule_name.setDisplayName('PV Schedule Name')
    args << pv_schedule_name

    # Storage Tank Volume
    storage_vol = OpenStudio::Measure::OSArgument.makeDoubleArgument('storage_vol', true)
    storage_vol.setDisplayName('Storage Tank Volume (m3)')
    storage_vol.setDefaultValue(0.19)
    args << storage_vol
 

    return args
  end

  def run(model, runner, user_arguments)
    super(model, runner, user_arguments) # Do **NOT** remove this line

    # Use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # Retrieve arguments
    obj_name = runner.getStringArgumentValue('obj_name', user_arguments)
    surf_name = runner.getStringArgumentValue('surf_name', user_arguments)
    work_fluid = runner.getStringArgumentValue('work_fluid', user_arguments)
    wf_design_flowrate = runner.getDoubleArgumentValue('design_flow_rate', user_arguments)
    per_name = runner.getStringArgumentValue('per_name', user_arguments)
    fract_of_surface = runner.getDoubleArgumentValue('fract_of_surface', user_arguments)
    therm_eff = runner.getStringArgumentValue('therm_eff', user_arguments)
    ther_eff_val = runner.getDoubleArgumentValue('ther_eff_val', user_arguments)
    schedule_name = runner.getStringArgumentValue('schedule_name', user_arguments)
    fron_surf_emittance = runner.getDoubleArgumentValue('fron_surf_emittance', user_arguments)
    generator_name = runner.getStringArgumentValue('generator_name', user_arguments)
    # gen_surf_name = runner.getStringArgumentValue('gen_surf_name', user_arguments)
    frac_surf_area_with_pv = runner.getDoubleArgumentValue('frac_surf_area_with_pv', user_arguments)
    conversion_eff = runner.getStringArgumentValue('conversion_eff', user_arguments)
    conversion_eff_val = runner.getDoubleArgumentValue('conversion_eff_val', user_arguments)
    pv_schedule_name = runner.getStringArgumentValue('pv_schedule_name', user_arguments)
    storage_vol = runner.getDoubleArgumentValue('storage_vol', user_arguments)
    plant_loop_name = runner.getStringArgumentValue('plant_loop_name', user_arguments)
    air_loop_name = runner.getStringArgumentValue('air_loop_name', user_arguments)


    # Validate selected surface
    pvt_surfaces = model.getSurfaceByName(surf_name)
    if pvt_surfaces.empty?
      runner.registerError("The selected surface '#{surf_name}' was not found in the model.")
      return false
    end
    pvt_surface = pvt_surfaces.get

    # Validate selected schedule
    schedule = model.getScheduleByName(schedule_name)
    if schedule.empty?
      runner.registerError("The selected schedule '#{schedule_name}' was not found in the model.")
      return false
    end
    schedule = schedule.get


    # Validate selected PV Generator schedule
    gen_schedule = model.getScheduleByName(pv_schedule_name)
    if gen_schedule.empty?
      runner.registerError("The selected schedule '#{pv_schedule_name}' was not found in the model.")
      return false
    end
    gen_schedule = gen_schedule.get


    # PlantLoop nodes
    plant_loops = model.getPlantLoopByName(plant_loop_name.chomp)
    if not plant_loops.empty?
      plant_loop = plant_loops.get
    end
    runner.registerInfo("The Plant Loop object is #{plant_loop.nameString}")

    # Retrieve all WaterHeaterMixed objects in the model
    # This water heater will later be added to plant loop
    water_heaters = model.getWaterHeaterMixeds
    if water_heaters.empty?
      runner.registerError('No WaterHeaterMixed objects found in the model.')
      return false
    end
    water_heater = water_heaters.first
    runner.registerInfo("Water heater retrieved: #{water_heater.nameString}")

    # Airloop Outdoor Air nodes
    oa_loops = model.getAirLoopHVACOutdoorAirSystemByName(air_loop_name.chomp)
    if not oa_loops.empty?
      oa_loop = oa_loops.get
      outdoorAirNodes = oa_loop.outboardOANode

      if not outdoorAirNodes.empty?
        outdoorAirNode = outdoorAirNodes.get
      end

    end
    runner.registerInfo("The outdoor air supply node is #{outdoorAirNode.nameString}")

    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PVT object named '#{obj_name}' on surface '#{surf_name}' using schedule '#{schedule_name}'.")
    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PV Generator object named '#{generator_name}' on surface '#{surf_name}' using schedule '#{pv_schedule_name}'.")
    
    # Register initial and final condition
    runner.registerInitialCondition("A PVT object named '#{obj_name}' will use schedule '#{schedule_name}'.")


    ## Creating PVT object
    #https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-1.11.0-doc/utilities_idd/html/classopenstudio_1_1_solar_collector___flat_plate___photovoltaic_thermal_fields.html

    # Adding the PVT collector 
    pv_collector = OpenStudio::Model::SolarCollectorFlatPlatePhotovoltaicThermal.new(model)
    # plant_loop.addSupplyBranchForComponent(pv_collector)
    pv_collector.setName(obj_name)
    pv_collector.setSurface(pvt_surface)

    if work_fluid == "Air"
      pv_collector.addToNode(outdoorAirNode)
      runner.registerInfo("PV Collector added to Outdoor Airloop Ventilation")
    else
      # Existing WaterHeaterMixed Removed. Here the water heater component earlier saved as OS component is 
      # retrived as IDD component to remove.
      plant_components = plant_loop.supplyComponents('OS:WaterHeater:Mixed'.to_IddObjectType)
      plant_component = plant_components.first.to_WaterHeaterMixed.get
      plant_loop.removeSupplyBranchWithComponent(plant_component)
      runner.registerInfo("PlantLoop component named #{plant_component.nameString} is removed from branch")


      # Adding a new storage connected to plantloop
      storage_water_heater = OpenStudio::Model::WaterHeaterMixed.new(model)
      storage_water_heater.setName('Storage Hot Water Tank')
      storage_water_heater.setTankVolume(storage_vol)
      storage_water_heater.setHeaterMaximumCapacity(0.0)

      # plant_loop.addSupplyBranchForComponent(pv_collector)
      plant_loop.addSupplyBranchForComponent(storage_water_heater)
      storage_inlet_node = ""
      storage_outlet_node = ""
      # WaterHeaterMixed nodes
      plant_loop.supplyComponents('OS:WaterHeater:Mixed'.to_IddObjectType).each do |storage_obj|
        runner.registerInfo("Storage tank name is #{storage_obj.nameString}")
        water_storage = storage_obj.to_WaterHeaterMixed.get

        if water_storage.nameString == "Storage Hot Water Tank"
          storage_outlet_node = water_storage.useSideOutletModelObject.get.to_Node.get
          storage_inlet_node = water_storage.useSideInletModelObject.get.to_Node.get
          runner.registerInfo("The water storage outlet node is #{storage_outlet_node.nameString}")
          runner.registerInfo("The water storage inlet node is #{storage_inlet_node.nameString}")
        end
      end
      pv_collector.addToNode(storage_inlet_node)
      runner.registerInfo("PV Collector added to Plant Loop Storage at #{storage_inlet_node.nameString}")
    end

    # Adding the initial water heater
    # plant_loop.addSupplyBranchForComponent(water_heater)
    # runner.registerInfo("Water heater added back: #{water_heater.nameString}")

    # create the pv_generator
    pv_generator = OpenStudio::Model::GeneratorPhotovoltaic.simple(model)
    pv_generator.setSurface(pvt_surface)
    # create the inverter
    inverter = OpenStudio::Model::ElectricLoadCenterInverterSimple.new(model)
    # create the distribution system
    elcd = OpenStudio::Model::ElectricLoadCenterDistribution.new(model)
    elcd.addGenerator(pv_generator)
    elcd.setInverter(inverter)
    # Assign the PV Generator to the collector
    pv_collector.setGeneratorPhotovoltaic(pv_generator)
    pv_collector.autosizeDesignFlowRate


    pv_collector_performance = pv_collector.solarCollectorPerformance.to_SolarCollectorPerformancePhotovoltaicThermalSimple.get
    pv_collector_performance.setName(per_name)
    pv_collector_performance.setFractionOfSurfaceAreaWithActiveThermalCollector(fract_of_surface)
    # pv_collector_performance.setThermalConversionEﬀiciencyInputMode(therm_eff)
    pv_collector_performance.setThermalConversionEfficiency(ther_eff_val)
    pv_collector_performance.setFrontSurfaceEmittance(fron_surf_emittance)

    runner.registerFinalCondition("PVT object named '#{obj_name}' successfully added to surface '#{surf_name}' with schedule '#{schedule_name}'.")

    ## Set output variables 
    outputVariablePVT = false
    if outputVariablePVT
      collector.outputVariableNames.each do |var|
        OpenStudio::Model::OutputVariable.new(var, model)
      end
    end

    return true
  end
end

# Register the measure to be used by the application
AddPVT.new.registerWithApplication
