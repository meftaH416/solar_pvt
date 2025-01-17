# *******************************************************************************
# OpenStudio(R), Copyright (c) Alliance for Sustainable Energy, LLC.
# See also https://openstudio.net/license
# *******************************************************************************

# frozen_string_literal: true

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

    # Name of the SolarCollectorPerformance object
    per_name = OpenStudio::Measure::OSArgument.makeStringArgument('per_name', true)
    per_name.setDisplayName('SolarCollectorPerformance:PhotovoltaicThermal Name')
    per_name.setDefaultValue('Performance Obj')
    args << per_name

    # Photovoltaic Generator Name
    generator_name = OpenStudio::Measure::OSArgument.makeStringArgument('generator_name', true)
    generator_name.setDisplayName('Generator:Photovoltaic Name')
    generator_name.setDefaultValue('Generator Obj')
    args << generator_name

    # Working fluid type
    chs = OpenStudio::StringVector.new
    chs << "Water"
    chs << "Air"
    work_fluid = OpenStudio::Measure::OSArgument::makeChoiceArgument('work_fluid', chs, true)
    work_fluid.setDisplayName('Working fluid type (Air or Water)')
    args << work_fluid

    # Design flow rate
    wf_dfrate = OpenStudio::Measure::OSArgument.makeStringArgument('wf_dfrate', true)
    wf_dfrate.setDisplayName('Design flow rate (m3/s)')
    wf_dfrate.setDefaultValue('Autosize')
    args << wf_dfrate

    ## SolarCollectorPerformance:PhotovoltaicThermal:Simple
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
    ther_eff_val.setDefaultValue(0.2)
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
    schedule_name = runner.getStringArgumentValue('schedule_name', user_arguments)

    # Validate selected surface
    surface = model.getSurfaceByName(surf_name)
    if surface.empty?
      runner.registerError("The selected surface '#{surf_name}' was not found in the model.")
      return false
    end
    surface = surface.get

    # Validate selected schedule
    schedule = model.getScheduleByName(schedule_name)
    if schedule.empty?
      runner.registerError("The selected schedule '#{schedule_name}' was not found in the model.")
      return false
    end
    schedule = schedule.get

    # Placeholder for creating a PVT object
    runner.registerInfo("Creating a PVT object named '#{obj_name}' on surface '#{surf_name}' using schedule '#{schedule_name}'.")

    # Register initial and final condition
    runner.registerInitialCondition("A PVT object named '#{obj_name}' will use schedule '#{schedule_name}'.")
    runner.registerFinalCondition("PVT object named '#{obj_name}' successfully added to surface '#{surf_name}' with schedule '#{schedule_name}'.")

    return true
  end
end

# Register the measure to be used by the application
AddPVT.new.registerWithApplication