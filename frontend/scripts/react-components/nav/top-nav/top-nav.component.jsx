import React from 'react';
import PropTypes from 'prop-types';
import cx from 'classnames';
import throttle from 'lodash/throttle';
import NavLinksList from 'react-components/nav/nav-links-list.component';
import LocaleSelector from 'react-components/nav/locale-selector/locale-selector.container';

class TopNav extends React.PureComponent {
  static getDownloadPdfLink() {
    const pageTitle = encodeURIComponent(document.getElementsByTagName('title')[0].innerText);
    const currentUrlBase = NODE_ENV_DEV
      ? document.location.href.replace('localhost:8081', 'staging.trase.earth')
      : document.location.href;
    const currentUrl = encodeURIComponent(`${currentUrlBase}&print=true`);
    return `${PDF_DOWNLOAD_URL}?filename=${pageTitle}&url=${currentUrl}`;
  }

  constructor(props) {
    super(props);
    this.state = {
      backgroundVisible: false
    };
    this.navLinkProps = {
      exact: false,
      strict: false,
      isActive: null
    };
    this.setBackground = throttle(this.setBackground.bind(this), 300);
    window.addEventListener('scroll', this.setBackground);
  }

  componentWillUnmount() {
    this.setBackground.cancel();
    window.removeEventListener('scroll', this.setBackground);
  }

  setBackground() {
    const { pageOffset } = this.props;
    const { backgroundVisible } = this.state;
    const hasOffset = typeof pageOffset !== 'undefined';
    if (hasOffset && window.pageYOffset > pageOffset && !backgroundVisible) {
      this.setState({ backgroundVisible: true });
    } else if (hasOffset && window.pageYOffset <= pageOffset && backgroundVisible) {
      this.setState({ backgroundVisible: false });
    }
  }

  render() {
    const { printable, links, showLogo, className } = this.props;
    const { backgroundVisible } = this.state;
    const decoratedLinks = showLogo && [
      {
        name: 'Home',
        page: 'home',
        linkClassName: 'top-nav-link -logo',
        linkActiveClassName: 'top-nav-link -logo',
        children: <img src="/images/logos/logo-trase-nav.png" alt="trase" />
      },
      ...links
    ];
    return (
      <div className={cx('c-nav', { '-has-background': backgroundVisible }, className)}>
        <div className="row align-justify">
          <div className="column medium-8">
            <div className="top-nav-item-list-container">
              <NavLinksList
                links={decoratedLinks || links}
                listClassName="top-nav-item-list"
                itemClassName="top-nav-item"
                linkClassName="top-nav-link"
                linkActiveClassName="top-nav-link -active"
                navLinkProps={this.navLinkProps}
              />
            </div>
          </div>
          <div className="column medium-2">
            <div className="top-nav-item-list-container -flex-end">
              <ul className="top-nav-item-list">
                <li className="top-nav-item">
                  <LocaleSelector />
                </li>
                {printable && (
                  <li className="top-nav-item">
                    <a href={TopNav.getDownloadPdfLink()} target="_blank" rel="noopener noreferrer">
                      <svg className="icon icon-download-pdf">
                        <use xlinkHref="#icon-download-pdf" />
                      </svg>
                    </a>
                  </li>
                )}
              </ul>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

TopNav.propTypes = {
  className: PropTypes.string,
  pageOffset: PropTypes.number,
  printable: PropTypes.bool,
  links: PropTypes.array,
  showLogo: PropTypes.bool
};

TopNav.defaultProps = {
  pageOffset: 0
};

export default TopNav;
