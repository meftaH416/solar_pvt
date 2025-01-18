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
    work_fluid.setDisplayName('Working fluid type (Air or Water)')
    args << work_fluid

    # Design flow rate
    wf_dfrate = OpenStudio::Measure::OSArgument.makeDoubleArgument('wf_dfrate', true)
    wf_dfrate.setDisplayName('Design flow rate (m3/s)')
    wf_dfrate.setDefaultValue(0.00005)
    args << wf_dfrate


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

    # Surface name for generator (dynamic choice argument)
    gen_surf_name = OpenStudio::Measure::OSArgument.makeChoiceArgument('gen_surf_name', surf_names, true)
    gen_surf_name.setDisplayName('PV Generator Surface Name')
    args << gen_surf_name

    
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
    wf_design_flowrate = runner.getDoubleArgumentValue('wf_dfrate', user_arguments)
    per_name = runner.getStringArgumentValue('per_name', user_arguments)
    fract_of_surface = runner.getDoubleArgumentValue('fract_of_surface', user_arguments)
    therm_eff = runner.getStringArgumentValue('therm_eff', user_arguments)
    ther_eff_val = runner.getDoubleArgumentValue('ther_eff_val', user_arguments)
    schedule_name = runner.getStringArgumentValue('schedule_name', user_arguments)
    fron_surf_emittance = runner.getDoubleArgumentValue('fron_surf_emittance', user_arguments)
    generator_name = runner.getStringArgumentValue('generator_name', user_arguments)
    gen_surf_name = runner.getStringArgumentValue('gen_surf_name', user_arguments)
    frac_surf_area_with_pv = runner.getDoubleArgumentValue('frac_surf_area_with_pv', user_arguments)
    conversion_eff = runner.getStringArgumentValue('conversion_eff', user_arguments)
    conversion_eff_val = runner.getDoubleArgumentValue('conversion_eff_val', user_arguments)
    pv_schedule_name = runner.getStringArgumentValue('pv_schedule_name', user_arguments)


    # Validate selected surface
    pvt_surface = model.getSurfaceByName(surf_name)
    if pvt_surface.empty?
      runner.registerError("The selected surface '#{surf_name}' was not found in the model.")
      return false
    end
    pvt_surface = pvt_surface.get

    # Validate selected schedule
    schedule = model.getScheduleByName(schedule_name)
    if schedule.empty?
      runner.registerError("The selected schedule '#{schedule_name}' was not found in the model.")
      return false
    end
    schedule = schedule.get

    # Validate PV Generator selected surface
    gen_surface = model.getSurfaceByName(gen_surf_name)
    if gen_surface.empty?
      runner.registerError("The selected surface '#{gen_surf_name}' was not found in the model.")
      return false
    end
    gen_surface = gen_surface.get

    # Validate selected PV Generator schedule
    gen_schedule = model.getScheduleByName(pv_schedule_name)
    if gen_schedule.empty?
      runner.registerError("The selected schedule '#{pv_schedule_name}' was not found in the model.")
      return false
    end
    gen_schedule = gen_schedule.get


    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PVT object named '#{obj_name}' on surface '#{surf_name}' using schedule '#{schedule_name}'.")
    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PV Generator object named '#{generator_name}' on surface '#{gen_surf_name}' using schedule '#{pv_schedule_name}'.")
    
    # Register initial and final condition
    runner.registerInitialCondition("A PVT object named '#{obj_name}' will use schedule '#{schedule_name}'.")

    ## Creating PVT object
    #https://openstudio-sdk-documentation.s3.amazonaws.com/cpp/OpenStudio-1.11.0-doc/utilities_idd/html/classopenstudio_1_1_solar_collector___flat_plate___photovoltaic_thermal_fields.html
    
    pvt_object = OpenStudio::Model::SolarCollectorFlatPlatePhotovoltaicThermal.new(model)
    pvt_object.setName(obj_name)
    pvt_object.setSurface(pvt_surface)
    pvt_object.setThermalWorkingFluidType(work_fluid)
    pvt_object.setDesignFlowRate(wf_design_flowrate)


    pvt_object_performance = pvt_object.SolarCollectorPerformancePhotovoltaicThermalSimple
    pvt_object_performance.setName(per_name)




    pvt_object.setPhotovoltaicName(generator_name)




    runner.registerFinalCondition("PVT object named '#{obj_name}' successfully added to surface '#{surf_name}' with schedule '#{schedule_name}'.")

    return true
  end
end

# Register the measure to be used by the application
AddPVT.new.registerWithApplication