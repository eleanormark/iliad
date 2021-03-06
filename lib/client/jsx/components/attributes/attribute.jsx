// Framework libraries.
import * as React from 'react';
import * as ReactRedux from 'react-redux';

import {reviseDocument} from '../../actions/magma_actions';
import SlowTextInput from '../inputs/slow_text_input';

export class Attribute extends React.Component{
  renderEdit(){
    let {document, template, attribute, revision, reviseDocument} = this.props;
    let input_props = {
      className: 'full_text',
      placeholder: attribute.placeholder,
      onChange: (value)=>{
        reviseDocument(document, template, attribute, value);
      },
      defaultValue: (revision == null) ? '' : revision
    };

    return <SlowTextInput {...input_props} />;
  }

  render(){
    return(
      <div className='value'>

        {(this.props.mode == 'edit') ? this.renderEdit() : this.props.value}
      </div>
    );
  }
}

const mapDispatchToProps = (dispatch, own_props)=>{
  return {
    reviseDocument: (doc, tmplt, attr, rev_val)=>{
      dispatch(reviseDocument(doc, tmplt, attr, rev_val));
    }
  };
};

export const AttributeContainer = ReactRedux.connect(
  null,
  mapDispatchToProps
)(Attribute);
