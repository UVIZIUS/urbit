import React, { Component } from 'react';
import { Row, Icon, Text } from '@tlon/indigo-react';
import defaultApps from '~/logic/lib/default-apps';
import Sigil from '~/logic/lib/sigil';

export class OmniboxResult extends Component {
  constructor(props) {
    super(props);
    this.state = {
      isSelected: false,
      hovered: false
    };
    this.setHover = this.setHover.bind(this);
    this.result = React.createRef();
  }

  componentDidUpdate(prevProps) {
    const { props, state } = this;
    if (prevProps &&
      !state.hovered &&
      prevProps.selected !== props.selected &&
      props.selected === props.link
      ) {
        this.result.current.scrollIntoView({ block: 'nearest' });
      }
  }

  getIcon(icon, dark, selected, link) {
    // graphicStyle is only necessary for pngs
    //
    //TODO can be removed after indigo-react 1.2
    //which includes icons for apps
    let graphicStyle = {};

    if (icon.toLowerCase() !== 'dojo') {
      graphicStyle = (!dark && this.state.hovered) ||
        selected === link ||
        (dark && !(this.state.hovered || selected === link))
        ? { filter: 'invert(1)' }
        : { filter: 'invert(0)' };
    } else {
      graphicStyle =
        (!dark && this.state.hovered) ||
          selected === link ||
          (dark && !(this.state.hovered || selected === link))
          ? { filter: 'invert(0)' }
          : { filter: 'invert(1)' };
    }

    const iconFill = this.state.hovered || selected === link ? 'white' : 'black';
    const sigilFill = this.state.hovered || selected === link ? '#3a8ff7' : '#ffffff';

    let graphic = <div />;
    if (defaultApps.includes(icon.toLowerCase()) || icon.toLowerCase() === 'links') {
      graphic =
        <img className="mr2 v-mid dib" height="16"
          width="16" src={`/~landscape/img/${icon.toLowerCase()}.png`}
          style={graphicStyle}
        />;
    } else if (icon === 'logout') {
      graphic = <Icon display="inline-block" verticalAlign="middle" icon='ArrowWest' mr='2' size='16px' fill={iconFill} />;
    } else if (icon === 'profile') {
      graphic = <Sigil color={sigilFill} classes='dib v-mid mr2' ship={window.ship} size={16} />;
    } else {
      graphic = <Icon verticalAlign="middle" mr='2' size="16px" fill={iconFill} />;
    }

    return graphic;
  }

  setHover(boolean) {
    this.setState({ hovered: boolean });
  }

  render() {
    const { icon, text, subtext, link, navigate, selected, dark } = this.props;

    const graphic = this.getIcon(icon, dark, selected, link);

    return (
        <Row
          py='2'
          px='2'
          display='flex'
          flexDirection='row'
          style={{ cursor: 'pointer' }}
          onMouseEnter={() => this.setHover(true)}
          onMouseLeave={() => this.setHover(false)}
          backgroundColor={
            this.state.hovered || selected === link ? 'blue' : 'white'
          }
          onClick={navigate}
          width="100%"
          ref={this.result}
        >
          {this.state.hovered || selected === link ? (
            <>
            {graphic}
              <Text
                display="inline-block"
                verticalAlign="middle"
                color='white'
                maxWidth="60%"
                style={{ 'flex-shrink': 0 }}
                mr='1'>
                {text}
              </Text>
            <Text pr='2'
            display="inline-block"
            verticalAlign="middle"
            color='white'
            width='100%'
            textAlign='right'
            >
                {subtext}
              </Text>
            </>
          ) : (
            <>
            {graphic}
              <Text
                mr='1'
                display="inline-block"
                verticalAlign="middle"
                maxWidth="60%"
                style={{ 'flex-shrink': 0 }}
              >
              {text}
            </Text>
              <Text
                pr='2'
                display="inline-block"
                verticalAlign="middle"
                gray
                width='100%'
                textAlign='right'
              >
                {subtext}
              </Text>
            </>
          )}
        </Row>
    );
  }
}

export default OmniboxResult;
