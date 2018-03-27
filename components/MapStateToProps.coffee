noflo = require 'noflo'

# Build up display model of runtime from runtime definition and status
populateRuntime = (state) ->
  unless state.runtime?.id
    return null
  state.runtimeStatuses = {} unless state.runtimeStatuses
  state.runtimeExecutions = {} unless state.runtimeExecutions
  runtime =
    definition: state.runtime
    status: state.runtimeStatuses[state.runtime.id] or {}
    execution: state.runtimeExecutions[state.runtime.id] or {
      running: false
      label: 'not started'
    }
  return runtime

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Map application state to UI properties'
  c.inPorts.add 'state',
    datatype: 'object'
    description: 'Full application state'
  c.inPorts.add 'updated',
    datatype: 'object'
    description: 'Updated application state values'
  c.outPorts.add 'props',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'state', 'updated'
    [state, updated] = input.getData 'state', 'updated'
    props = {}
    Object.keys(updated).forEach (key) ->
      switch key
        when 'componentLibraries'
          # Filter UI components to current runtime
          if state.runtime?.id
            props.componentLibrary = updated[key][state.runtime.id] or []
          return
        when 'runtime'
          props.runtime = populateRuntime state
          return
        when 'runtimeStatuses'
          props.runtime = populateRuntime state
          return
        when 'runtimeExecutions'
          props.runtime = populateRuntime state
          return
        else
          props[key] = updated[key]
    output.sendDone
      props: props
