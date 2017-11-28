// Framework libraries.
import * as React from 'react';

// Class imports.
import AttributeViewer from '../attributes/attribute_viewer';

export default class BrowserPane extends React.Component{
  constructor(props){
    super(props);
  }

  renderTitle(){
    let {title, name} = this.props.pane;
    if(title) return <div className='title' title={name}>{title}</div>;
    return null;
  }

  renderAttributes(){
    let {template, doc, revision, pane, mode} = this.props;

    let display = Object.keys(pane.attributes).map((attr_name, index)=>{

      // The Timur view attribute.
      let attr = pane.attributes[attr_name];

      // The data of the attribute
      let value = doc[attr_name];

      // Setting the edit mode and revision of the attribute.
      let revised_value = doc[attr_name];
      if(attr_name in revision) revised_value = revision[attr_name];
      let revised = (mode == 'edit' && value != revised_value);

      let attr_viewer_props = {
        template,
        value,
        attribute: attr,
        document: doc,
        revision: revised_value
      };

      return(
        <div key={attr_name} className='attribute'>

          <div className={revised ? 'name revised' : 'name'} title={attr.desc}>

            {(attr.display_name == null) ? attr.title : attr.display_name}
          </div>
          <AttributeViewer {...attr_viewer_props} />
        </div>
      );
    });

    return display;
  }

  render(){
    if(Object.keys(this.props.pane.attributes).length == 0){
      return <div style={{'display': 'none'}} />;
    }

    return(
      <div className='pane'>

        {this.renderTitle()}
        <div className='attributes'>

          {this.renderAttributes()}
        </div>
      </div>
    );
  }
}