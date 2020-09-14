import React from 'react';
import kebabCase from 'lodash/kebabCase';
import PropTypes from 'prop-types';
import Link from 'gatsby-link';
import { css } from 'react-emotion';
import styled from 'react-emotion';

import { theme, setMood, setMode } from '../../config/theme';
import { Orb } from './Orb';

const OrbHolderDiv = styled.div`
  transition: all 0.65s;
  display: grid;
  position: absolute;
  width: 100%;
  max-width: ${props => props.theme.layout.max};
  box-shadow: ${props => props.theme.set.light.shadow.feature.small.main};
  border-radius: ${props => props.theme.borderRadius.main};
  background-image: linear-gradient(360deg, rgba(0, 0, 0, 0.75) 0%, rgba(0, 0, 0, 0) 75%);
  transform: translateY(-24rem);
  justify-items: end;
  margin-left: -1.5rem;
  scrolling: no;
  top: 3rem;
  @media (min-width: ${props => props.theme.layout.max}) {
    margin-left: 0.75rem;
    padding: 0;
  }
  @media (max-width: 675px) {
    top: 6rem;
  }
`;

const OrbContainerDiv = styled.div`
  height: 14.5rem;
  padding-top: 1rem;
  padding-bottom: 1rem;
  margin-bottom: 1rem;
  padding-left: 0.5rem;
  padding-right: 0.5rem;
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  grid-column-gap: 1rem;
  grid-row-gap: 2rem;
  @media (max-width: 500px) {
    width: 100%;
  }
  @media (max-width: 675px) {
    margin-top: -2rem;
  }
`;

const OrbH2 = styled.h2`
  font-size: 1rem;
  margin-right: 1.5rem;
  margin-bottom: -0.05rem;
  color: ${props => props.theme.colors.pure.white};
  text-shadow: ${props => props.theme.set.light.shadow._3dThin};
`;

const RedX = styled.h2`
  color: darkred;
  font-size: 5rem;
  max-height: 3rem;
  transition: all 0.25s;
  padding-top: 0.5rem;
  padding-left: 0.25rem;
  text-shadow: ${props => props.theme.set.light.shadow._3dThin};
  &:focus,
  &:hover {
    color: red;
    cursor: pointer;
    font-size: 6rem;
    padding: 0;
  }
`;

const OverflowDiv = styled.div`
  height: 0;
  width: 100%;
  overflow: hidden;
  transition: all 4s;
`;

let storedTheme = '';
let orbsInited = false;
let unthemed = true;
const setTheme = () => {
  if (!unthemed) {
    return;
  }

  // alert(`
  //   ${storedTheme} ${theme.set.id}
  //   ${localStorage.getItem('mood')}
  //   ${theme.set.mode} ${localStorage.getItem('mode')}
  //   `);

  // Debug force init:
  // localStorage.setItem('mood', `Vampire`);
  // localStorage.setItem('mode', `Light`);
  // storedTheme = localStorage.getItem('mood');
  // orbClick2(theme.colors.mood[`${storedTheme.toLowerCase()}`]);
  // return;

  if (typeof Storage !== 'undefined' && localStorage !== null) {
    if (localStorage.getItem('mood') !== null && localStorage.getItem('mood') !== 'Default') {
      storedTheme = localStorage.getItem('mood');
      setMood(theme, theme.colors.mood[`${storedTheme.toLowerCase()}`]);
    } else if (typeof window !== 'undefined' && localStorage.getItem('mode') !== 'Dark') {
      if ((window.matchMedia && window.matchMedia(/(prefers-color-scheme: dark)/gi).matches)) {
        setMood(theme, theme.colors.mood[`graphene`]);
        setMode('Dark');
      }
    }
    // alert(`mode: ${localStorage.getItem('mode')}`);

    if (localStorage.getItem('mode') === 'Dark') {
      setMode(localStorage.getItem('mode'));
      // alert(localStorage.getItem('mode'));
    }
  }
  unthemed = false;
};

const closeOrbContainer = () => {
  if (document.getElementById('OrbHolderDiv').style.transform !== 'translateY(-24rem)') {
    document.getElementById('OrbHolderDiv').style.transform = 'translateY(-24rem)';
  }
  if (typeof Storage !== 'undefined') {
    localStorage.setItem('mood', `${theme.set.id}`);
    localStorage.setItem('mode', `${theme.set.mode}`);
    // alert(`set: ${theme.set.id} ${localStorage.getItem('mood')}`);
  }
};

const openOrbContainer = () => {
  if (document.getElementById('OrbHolderDiv').style.transform !== 'translateY(1.5rem)') {
    document.getElementById('OrbHolderDiv').style.transform = 'translateY(1.5rem)';
  }
  if (!orbsInited) {
    // alert(`mood${theme.set.mode}${theme.set.id} ${theme.set.mode.toLowerCase()}${theme.set.id}`);
    if (theme.set.id !== 'Default') {
      document.getElementById(`mood${theme.set.mode}${theme.set.id}`).style.opacity = 0;
      document.getElementById(`${theme.set.mode.toLowerCase()}${theme.set.id}`).style.opacity = 1;
      orbsInited = true;
    }
  }
};

const OrbContainer = ({ type, mood }) => {
  return (
    <OverflowDiv id="OverflowDiv">
      <OrbHolderDiv id="OrbHolderDiv">
        <OrbContainerDiv>
          <Orb mood={theme.colors.mood.lotus} />
          <Orb mood={theme.colors.mood.sequoia} />
          <Orb mood={theme.colors.mood.ivy} />
          <Orb mood={theme.colors.mood.graphene} />
          <RedX onClick={e => closeOrbContainer()}>X</RedX>
          <Orb mood={theme.colors.mood.lagoon} />
          <Orb mood={theme.colors.mood.orchid} />
          <Orb mood={theme.colors.mood.vampire} />
          <Orb mood={theme.colors.mood.spartan} />
          <div />
        </OrbContainerDiv>
        <OrbH2>
          {theme.set.id} [ {theme.set.mode} ]
        </OrbH2>
      </OrbHolderDiv>
    </OverflowDiv>
  );
};
export { OrbContainer, openOrbContainer, setTheme };

OrbContainer.propTypes = {
  mood: PropTypes.array,
  type: PropTypes.string,
};

OrbContainer.defaultProps = {
  type: 'mood',
};
