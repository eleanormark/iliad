import * as React from 'react';
import * as ReactRedux from 'react-redux';
import IdentifierSearch from './identifier_search';
import {toggleConfig, changeMode} from '../actions/timur_actions';

class TimurNav extends React.Component{
  constructor(props){
    super(props);
    this['state'] = {'open': false};
  }

  renderTabs(){
    var tabs = {
      browse: Routes.browse_path(PROJECT_NAME),
      search: Routes.search_path(PROJECT_NAME),
      map: Routes.map_path(PROJECT_NAME),
      manifest: Routes.manifests_path(PROJECT_NAME),
    }

    return(
      Object.keys(tabs).map((name)=>{
        return(
          <a className='nav-menu-btn' key={Math.random()} href={tabs[name]}>

            {name}
          </a>
        );
      })
    );
  }

  renderActivityTab(){
    return null;
    if(!this.props.can_edit) return null;

    return(
      <a className='nav-menu-btn' href='#'>

        {'ACTIVITY'}
      </a>
    );

    /* Need to fix activity_path
    return(
      <a className='nav-menu-btn' href={Routes.activity_path()}>

        {'Activity'}
      </a>
    );
    */
  }

  renderHelpTab(){
    return null;
    var help_props = {
      'className': 'nav-menu-btn',
      'href': '#',
      'onClick': (e)=>{
        this.props.toggleConfig('help_shown');
      }
    };

    return(
      <a {...help_props}>

        {this.props.helpShown ? 'HIDE HELP' : 'HELP'}
      </a>
    );
  }

  toggleUserPanel(){
    var open = (this['state']['open']) ? false : true;
    this.setState({'open': open});
  }

  closeUserPanel(event){
    this.setState({'open': false});
  }

  renderUserMenu(){
    var height = (this['state']['open']) ? 'auto' : '100%';
    var userDropdownGroupProps = {
      'className': 'user-menu-dropdown-group',
      'style': {'height': height},
      'onMouseLeave': this['closeUserPanel'].bind(this)
    };

    var userMenuButtonProps = {
      'className': 'user-menu-dropdown-btn',
      'onClick': this['toggleUserPanel'].bind(this)
    };

    return(
      <div {...userDropdownGroupProps}>

        <button {...userMenuButtonProps}>

          {this.props.user}
          <div className='user-menu-arrow-group'>

            <i className='fa fa-caret-down' aria-hidden='true'></i>
          </div>
        </button>
        <div className='user-dropdown-menu'>

          <div className='user-dropdown-menu-item'>

            {'LOG OUT'}
          </div>
        </div>
      </div>
    );
  }

  render(){

    return(
      <div id='header-container'>

        <div id='title-menu'>

          <button className='title-menu-btn'>

            {'Timur'}
            <br />
            <span className='title-menu-btn-sub'>

              {'DATA BROWSER'}
            </span>
          </button>
          <img id='ucsf-logo' src='/assets/ucsf_logo_dark.png' alt='' />
        </div>
        <div id='nav-menu'>

          {this.renderUserMenu()}
          <IdentifierSearch project_name={this.props.project_name} />
          {this.renderHelpTab()}
          {this.renderActivityTab()}
          {this.renderTabs()}
        </div>
        <div className='logo-container'>

          <img src='/assets/timur_logo_basic.png' alt='' />
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state, ownProps)=>{

  return {
    'helpShown': state.timur.help_shown,
    'exchanges': state.exchanges,
  };
};

const mapDispatchToProps = (dispatch, ownProps)=>{
  return {

    changeMode: function(){
      dispatch(changeMode());
    },

    toggleConfig: function(){
      dispatch(toggleConfig());
    }
  };
};

export default ReactRedux.connect(
  mapStateToProps,
  mapDispatchToProps
)(TimurNav);
