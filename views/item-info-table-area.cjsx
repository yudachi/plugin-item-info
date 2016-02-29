{Grid, Table, Input} = ReactBootstrap
{SlotitemIcon} = require "#{ROOT}/views/components/etc/icon"
Divider = require './divider'
path = require 'path'

ItemInfoTable = React.createClass
  shouldComponentUpdate: (nextProps) ->
    !_.isEqual(@props, nextProps)
  render: ->
    <tr className="vertical">
      <td className='item-name-td'>
        {
          <SlotitemIcon slotitemId={@props.iconIndex} />
        }
        {@props.name}
      </td>
      <td className='center'>{@props.total + ' '}<span style={fontSize: '12px'}>{'(' + @props.rest + ')'}</span></td>
      <td>
        <Table id='equip-table'>
          <tbody>
          {
            for alvList, alv in @props.levelCount
              continue unless alvList?
              for count, level in alvList
                if count?
                  <tr key={level}>
                    {
                      if @props.hasNoAlv and @props.hasNoLevel
                        <td style={width: '13%'}></td>
                      else
                        alvPrefix = if @props.hasNoAlv
                                      ''
                                    else if alv is 0
                                      <span className='item-alv-0'>O</span>
                                    else if alv <= 7
                                      <img className='item-alv-img' src={
                                          path.join(ROOT, 'assets', 'img', 'airplane', "alv#{alv}.png")
                                        }
                                      />
                                    else # unreachable
                                      ''

                        levelPrefix = if @props.hasNoLevel
                                        ''
                                      else if level is 10
                                        '★max'
                                      else
                                        '★' + level

                        <td style={width: '13%'}><span className='item-level-span'>{alvPrefix} {levelPrefix}</span> × {count}</td>
                    }
                    <td>
                    {
                      if @props.ships[level]?
                        for ship in @props.ships[level]
                          <div key={ship.id} className='equip-list-div'>
                            <span className='equip-list-div-span'>Lv.{ship.level}</span>
                            {ship.name}
                            {
                              if ship.count > 1
                                <span className='equip-list-number'>×{ship.count}</span>
                            }
                          </div>
                    }
                    </td>
                  </tr>
            }
          </tbody>
        </Table>
      </td>
    </tr>


alwaysTrue = -> true
ItemInfoTableArea = React.createClass
  getInitialState: ->
    rows: []
    filterName: alwaysTrue
  handleFilterNameChange: ->
    key = @refs.input.getValue()
    if key
      filterName = null
      match = key.match /^\/(.+)\/([gim]*)$/
      if match?
        try
          re = new RegExp match[1], match[2]
          filterName = re.test.bind(re)
      filterName ?= (name) -> name.indexOf(key) >= 0
    else
      filterName = alwaysTrue
    @setState {filterName}
  displayedRows: ->
    {filterName} = @state
    {rows, itemTypeChecked} = @props
    rows = rows.filter (row) ->
      row? and filterName(row.name) and itemTypeChecked[row.iconIndex]
    rows.sort (a, b) -> a.iconIndex - b.iconIndex || a.slotItemId - b.slotItemId
    for row in rows
      for shipsInLevel in row.ships
        shipsInLevel?.sort (a, b) -> b.level - a.level || a.id - b.id
    rows
  render: ->
    <div id='item-info-show'>
      <Divider text={__ 'Equipment Info'} />
      <Grid id="item-info-area">
        <Table striped condensed hover id="main-table">
          <thead className="slot-item-table-thead">
            <tr>
              <th className="center" style={width: '25%'}>
                <Input className='name-filter' type='text' ref='input' placeholder={__ 'Name'} onChange={@handleFilterNameChange}/>
              </th>
              <th className="center" style={width: '9%'}>{__ 'Total'}<span style={fontSize: '11px'}>{'(' + __('rest') + ')'}</span></th>
              <th className="center" style={width: '66%'}>{__ 'State'}</th>
            </tr>
          </thead>
          <tbody>
          {
            for row in @displayedRows()
              <ItemInfoTable
                key = {row.slotItemId}
                slotItemId = {row.slotItemId}
                name = {row.name}
                total = {row.total}
                rest = {row.total - row.used}
                ships = {row.ships}
                levelCount = {row.levelCount}
                hasNoLevel = {row.hasNoLevel}
                hasNoAlv = {row.hasNoAlv}
                iconIndex = {row.iconIndex}
              />
          }
          </tbody>
        </Table>
      </Grid>
    </div>

module.exports = ItemInfoTableArea
