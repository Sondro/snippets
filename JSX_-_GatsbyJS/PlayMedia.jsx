import React from 'react';
import PropTypes from 'prop-types';
import Link from 'gatsby-link';
import { css } from 'react-emotion';
import styled from 'react-emotion';
import { theme } from '../../config/theme';
import Triangle from '../icons/css/Triangle';

const Tri = styled(Triangle)`
  transform: rotate(45deg) scale(0.15);
  background-color: ${props => props.theme.set.dark.invertWhite};
  top: -4.8rem;
  left: -3.95rem;
  z-index: 99;
  opacity: 0.85;
  transition: ${props => props.theme.transitions.main.duration};
`;
const BgTri = styled(Triangle)`
  transform: rotate(45deg) scale(0.2);
  background-color: ${props => props.theme.set.dark.bgText};
  top: -14.75rem;
  left: -3.95rem;
  z-index: 98;
  opacity: 0.95;
  transition: ${props => props.theme.transitions.main.duration};
`;
const ShadowTri = styled(Triangle)`
  transform: rotate(45deg) scale(0.25);
  background-color: ${props => props.theme.colors.cool.lead};
  top: -24.7rem;
  left: -3.9rem;
  z-index: 97;
  opacity: 0.5;
  transition: ${props => props.theme.transitions.main.duration};
`;
const TriDiv = styled.div`
  position: fixed;
  left: 50%;
  top: 40%;
`;

const PlayMedia = ({ type }) => {
  let icon = '#';
  let playMediaDivClass = '';
  if (type === 'vid') {
    icon = '@';
    playMediaDivClass = ``;
  }
  return (
      <TriDiv>
        <Tri />
        <BgTri />
        <ShadowTri />
      </TriDiv>
  );
};

export default PlayMedia;

PlayMedia.propTypes = {
  type: PropTypes.string,
  img: PropTypes.string,
};

PlayMedia.defaultProps = {
  type: '',
  img: '',
};
