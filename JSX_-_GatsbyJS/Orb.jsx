import React from 'react';
import PropTypes from 'prop-types';
import Link from 'gatsby-link';
import { css } from 'react-emotion';
import styled from 'react-emotion';

import { theme, previewColors, getColor, setMood, updateSet, updateColors, setMode } from '../../config/theme';

// import { initOrbOn } from './OrbContainer';

const OrbWrap = styled.div`
  width: 5rem;
  height: 5.5rem;
`;

const LightOrbShadow = styled.div`
  position: relative;
  top: -6.38rem;
  width: 4rem;
  height: 0.8rem;
  border-radius: 50%;
  overflow: hidden;
  background: radial-gradient(50% 20%, rgba(0, 0, 0, 0.85) 100%, rgba(0, 0, 0, 0.85) 0%);
`;

const DarkOrbShadow = styled.div`
  position: relative;
  top: -17.92rem;
  width: 4rem;
  height: 0.8rem;
  border-radius: 50%;
  overflow: hidden;
  background: radial-gradient(50% 20%, rgba(0, 0, 0, 0.85) 100%, rgba(0, 0, 0, 0.85) 0%);
`;

const OrbDiv = styled.div`
  position: relative;
  display: inline-block;
  z-index: 3;
  width: 5rem;
  height: 5rem;
  border-radius: 50%;
  transition: all 0.25s;
`;

const DarkOrbWrap = styled.div`
  opacity: 0;
  transition: all 0.25s;
`;

const LightOrbWrap = styled.div`
  opacity: 1;
  transition: all 0.25s;
`;

let moodLightClass = '';
let moodDarkClass = '';
let lightClass = '';
let darkClass = '';

const len = 3;
const hslI = [4, 8, 13];
let init = false;
let path = '';
const totalObjs = 0;
let scrollY = 0;
let scrollX = 0;
let color = ['cyan', 'purple', 'magenta'];
let lightOpacity = 0;
let id = '';
let lastOrbOn = '';
// const defaultColor = [
//   `${previewColors.cool.light_main}`,
//   `${previewColors.cool.light_shadow}`,
//   `${previewColors.warm.light_glow}`,
//   `${previewColors.cool.dark_main}`,
//   `${previewColors.cool.dark_shadow}`,
//   `${previewColors.warm.dark_glow}`,
// ];
const defaultColor = [
  ``,
  ``,
  ``,
  ``,
  ``,
  ``,
];

let oldMode = '';

const orbClick = mood => {
  if (mood !== null) {
    if (scrollX !== window.pageXOffset) {
      scrollX = window.pageXOffset;
    }
    if (scrollY !== window.pageYOffset) {
      scrollY = window.pageYOffset;
    }
    // Force scroll back after page load:
    if (typeof setTimeout !== 'undefined') {
      setTimeout(() => {
        window.scrollTo(scrollX, scrollY);
      }, 0);
    }

    // Reset stored theme of orb
    if (theme.set.id !== 'Default' && !init) {
      document.getElementById(`${theme.set.mode.toLowerCase()}${theme.set.id}`).style.opacity = 0;
      document.getElementById(`mood${theme.set.mode}${theme.set.id}`).style.opacity = 1;

      init = true;
    }

    oldMode = theme.set.mode;

    if (mood.id === theme.set.id && theme.set.id !== 'Default') {
      updateColors(theme);

      if (document.getElementById(theme.lastNavOnId) !== null) {
        theme.cssNav = `
        color: white; 
        text-shadow: 0.25rem 0.2rem 0.5rem black,
        -1px -1px 0 ${theme.colors.fire.light}, 
        -1px 1px 0 ${theme.colors.fire.light}, 
        -1px 1px 0 ${theme.colors.fire.light},
        0px 1px 0 ${theme.colors.fire.light},
        1px -1px 0 ${theme.colors.fire.light},  
        1px 0px 0 ${theme.colors.fire.light}, 
        1px 1px 0 ${theme.colors.fire.light};
        `;

        document.getElementById(theme.lastNavOnId).style = theme.cssNav;
      }
      document.getElementById(`moodDark${mood.id}`).style.opacity = 1;
      document.getElementById(`moodLight${mood.id}`).style.opacity = 1;
      theme.set.id = 'Default';
      document.getElementById(`dark${mood.id}`).style.opacity = 0;
      document.getElementById(`light${mood.id}`).style.opacity = 0;
      if (oldMode === `Dark`) {
        updateSet(theme);
        setMode('Dark');
        return;
      }
      updateSet(theme);
      return;
    }
    if (theme.set.id !== 'Default') {
      updateColors(theme);
      theme.set.id = 'Default';
      if (oldMode === `Dark`) {
        setMood(theme, mood);
        setMode('Dark');
      } else {
        setMood(theme, mood);
      }
    } else if (oldMode === 'Dark') {
      setMood(theme, mood);
      setMode('Dark');
    } else {
      setMood(theme, mood);
    }

    // alert(`#5# ${theme.set.mode} old:${oldMode}`);

    if (lastOrbOn !== '') {
      document.getElementById(`moodDark${lastOrbOn}`).style.opacity = 1;
      document.getElementById(`moodLight${lastOrbOn}`).style.opacity = 1;
      document.getElementById(`dark${lastOrbOn}`).style.opacity = 0;
      document.getElementById(`light${lastOrbOn}`).style.opacity = 0;
    }

    document.getElementById(`moodDark${mood.id}`).style.opacity = 0;
    document.getElementById(`moodLight${mood.id}`).style.opacity = 0;

    document.getElementById(`dark${mood.id}`).style.opacity = 1;
    document.getElementById(`light${mood.id}`).style.opacity = 1;

    lastOrbOn = `${mood.id}`;
  }
};

const OrbLink = styled(Link)`
  position: absolute;
  overflow: hidden;
  height: 6.5rem;
  width: 6rem;
  padding-top: 0.5rem;
  &:focus,
  &:hover {
    ${OrbDiv} {
      width: 5.26rem;
      height: 5.26rem;
    }
    ${LightOrbShadow} {
      width: 4.26rem;
      height: 1.06rem;
    }
    ${DarkOrbShadow} {
      width: 4.26rem;
      height: 1.06rem;
    }
    .darkClass {
      display: grid;
      top: -11.65rem;
    }
    .lightClass {
      display: grid;
      top: -0.15rem;
    }
  }
`;

const Orb = ({ mood = null, type }) => {

  if (type !== 'mod') {
    if (mood === null) {
      color[0] = `${previewColors.cool.light_main}`;
      color[1] = `${previewColors.cool.light_shadow}`;
      color[2] = `${previewColors.warm.light_glow}`;
      color[3] = `${previewColors.cool.dark_main}`;
      color[4] = `${previewColors.cool.dark_shadow}`;
      color[5] = `${previewColors.warm.dark_glow}`;
    } else {
      let nowPreviewColors = new previewColors();
      defaultColor[0] = `${nowPreviewColors.cool.light_main}`;
      defaultColor[1] = `${nowPreviewColors.cool.light_shadow}`;
      defaultColor[2] = `${nowPreviewColors.warm.light_glow}`;
      defaultColor[3] = `${nowPreviewColors.cool.dark_main}`;
      defaultColor[4] = `${nowPreviewColors.cool.dark_shadow}`;
      defaultColor[5] = `${nowPreviewColors.warm.dark_glow}`;

      //nowPreviewColors = JSON.parse(JSON.stringify(previewColors));

      // alert(nowPreviewColors.cool.light_main);
      // alert(mood.id);
      nowPreviewColors.cool = getColor(hslI, len, nowPreviewColors.cool, mood.hslCool);
      nowPreviewColors.warm = getColor(hslI, len, nowPreviewColors.warm, mood.hslWarm);

      color[0] = `${nowPreviewColors.cool.light_main}`;
      color[1] = `${nowPreviewColors.cool.light_shadow}`;
      color[2] = `${nowPreviewColors.warm.light_glow}`;
      color[3] = `${nowPreviewColors.cool.dark_main}`;
      color[4] = `${nowPreviewColors.cool.dark_shadow}`;
      color[5] = `${nowPreviewColors.warm.dark_glow}`;
    }
  } else {
    lightOpacity = 1;
    color = ['cyan', 'purple', 'magenta'];
  }

  // alert(color[0]);
  darkClass = `
    opacity: 0;
    top: -11.6rem;
    background: radial-gradient(
      circle at 65% 15%, 
      white 0.1225rem, 
      ${defaultColor[3]} 5%, 
      ${defaultColor[4]} 60%, 
      ${defaultColor[5]} 82%
      );
      &:focus,
      &:hover {
      } 
  `;

  moodDarkClass = `
    top: -16.9rem;
    background: radial-gradient(
      circle at 65% 15%, 
      white 0.1225rem, 
      ${color[3]} 5%, 
      ${color[4]} 60%, 
      ${color[5]} 82%
      ); 
      &:focus,
      &:hover {
      } 
  `;

  lightClass = `
    opacity: 0;
    background: radial-gradient(
      circle at 65% 15%, 
      white 0.1225rem, 
      ${defaultColor[0]} 5%, 
      ${defaultColor[1]} 60%, 
      ${defaultColor[2]} 82%
      );
      &:focus,
      &:hover {
      } 
  `;

  moodLightClass = `
    left: 0rem;
    top: -5.4rem;
    opacity: 1;
    background: radial-gradient(
      circle at 65% 15%, 
      white 0.1225rem, 
      ${color[0]} 5%, 
      ${color[1]} 60%, 
      ${color[2]} 82%
      )
  `;

  if (typeof window !== 'undefined') {
    path = window.location.pathname;
  }
  if (mood !== null) {
    id = `${mood.id}`;
  }
  return (
    <React.Fragment>
      <OrbWrap>
        <OrbLink id={`orb${id}`} to={path} onClick={e => orbClick(mood)}>
          <LightOrbWrap className="lightOrbWrap">
            <OrbDiv id={`light${id}`} className={`${css(lightClass)} lightClass`} />
            <OrbDiv id={`moodLight${id}`} className={css(moodLightClass)} />
            <LightOrbShadow />
          </LightOrbWrap>
          <DarkOrbWrap className="darkOrbWrap">
            <OrbDiv id={`dark${id}`} className={`${css(darkClass)} darkClass`} />
            <OrbDiv id={`moodDark${id}`} className={css(moodDarkClass)} />
            <DarkOrbShadow />
          </DarkOrbWrap>
        </OrbLink>
      </OrbWrap>
    </React.Fragment>
  );
};

export { Orb, lastOrbOn };

Orb.propTypes = {
  mood: PropTypes.object,
  type: PropTypes.string,
};

Orb.defaultProps = {
  type: 'mood',
  mood: null,
};
