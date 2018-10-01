table.list{
    border-spacing: 0px; 
    border-collapse: collapsed;
}
table.list>thead{

}
.hide{
    display:none;
}
.mandatory{
    border-left: 2px solid red;
}
.data-invalid>input{
    color: red;
}
.data-invalid-message{
    display: none;
    color: red;
}
.data-invalid .data-invalid-message{
    display: block;
}
.placeholder{
    color: rgb(153, 153, 153);
    position: absolute;
    margin-left: 6px;
    margin-top: 4px;
    display: block;
}
#prod-page a{
    margin-right: 5px;
}
#prod-page a.active{
    color: blue;
    margin-right: 10px;
    margin-left: 5px;
}
.display,
.stts-closed-won .editor{
    display:none;
}
.stts-closed-won .display{
    display: inline;
}
caption{
    padding: 5px 10px;
    text-align:left;
    font-size: 1.1em;
    font-weight: bold;
}
.pagination{
    margin: 5px;
    min-width: 300px;
    text-align: right;
    display: inline-block;
    float:right;
    font-size: 11px;
    font-weight: normal;
}
.pagination>a{
    display:inline-block;
    padding-left: 3px;
    padding-right: 3px;

    border-left: 1px solid #cfcece;

    color: #015ba7;
    font-size: 10px;
    text-decoration: none;
}
.pagination>a:last-child{
    border-right: 1px solid #cfcece;
}
.pagination>a:not(.active):hover{
    text-decoration: underline;
    cursor: pointer;
    background-color: aliceblue;
}
.pagination>a.active{
    color: black;
    font-weight: bold;
}
.pagination .summary{
    padding-left: 15px;
}
body{
    padding:5px;
}
.bs3 .nav > li > a {
  padding: 13px 15px;
}
.bs3 .btn {
    padding:3px 10px;
}
.tab-content > .tab-pane {
  display: none;
  visibility: hidden;
}
.tab-content > .active {
  display: block;
  visibility: visible;
}
.bs3 .panel-heading {
    padding: 5px 15px;
}
.bs3 .panel-group {
    margin-bottom: 5px;
}
.bs3 .panel-heading .accordion-toggle:after {
    font-family: 'Glyphicons Halflings';  /* essential for enabling glyphicon */
    content: "\e114";    /* adjust as needed, taken from bootstrap.css */
    float: left;        /* adjust as needed */
    color: grey;         /* adjust as needed */
}
.bs3 .panel-heading .accordion-toggle.collapsed:after {
    content: "\e080";    /* adjust as needed, taken from bootstrap.css */
}
.bs3 .panel-title {
    padding-left: 10px;
}
body .pbBody table.list tr.headerRow th {
    border-width: 0px 1px 1px 1px;
}
body .pbBody table.list tr th, body .pbBody table.list tr td {
    padding: 5px;
}
.bs3 .panel-title {
    font-size: 14px;
}
.bs3 .disabled a {
    color:#ddd !important;
}
.bs3 .nav-pills.nav-wizard > li.disabled:hover .nav-arrow {
  border-color: transparent transparent transparent #eee;
}
.bs3 .nav-pills.nav-wizard > li.disabled:hover .nav-wedge {
  border-color: #eee #eee #eee transparent;
}
.bs3 .nav-pills.nav-wizard > li.disabled:hover a {
  background-color: #eee;
  color:#ddd;
}

.bs3 div.m-app-loading {
    position: fixed ;
    z-index: 999999;
}

.bs3 div.m-app-loading div.animated-container {
    background-color: #333333 ;
    bottom: 0px ;
    left: 0px ;
    opacity: 1.0 ;
    position: fixed ;
    right: 0px ;
    top: 0px ;
    z-index: 999999 ;
}

/* Used to initialize the ng-leave animation state. */
.bs3 div.m-app-loading div.animated-container.ng-leave {
    opacity: 1.0 ;
    transition: all linear 200ms ;
        -webkit-transition: all linear 200ms ;
}

/* Used to set the end properties of the ng-leave animation state. */
.bs3 div.m-app-loading div.animated-container.ng-leave-active {
    opacity: 0 ;
}

.bs3 div.m-app-loading div.messaging {
    color: #FFFFFF ;
    font-family: monospace ;
    left: 0px ;
    margin-top: -37px ;
    position: absolute ;
    right: 0px ;
    text-align: center ;
    top: 50% ;
}

.bs3 div.m-app-loading h1 {
    font-size: 26px ;
    line-height: 35px ;
    margin: 0px 0px 20px 0px ;
}

.bs3 div.m-app-loading p {
    font-size: 18px ;
    line-height: 14px ;
    margin: 0px 0px 0px 0px ;
}
.bs3 .btn-file {
    position: relative;
    overflow: hidden;
}
.bs3 .btn-file input[type=file] {
    position: absolute;
    top: 0;
    right: 0;
    min-width: 100%;
    min-height: 100%;
    font-size: 100px;
    text-align: right;
    filter: alpha(opacity=0);
    opacity: 0;
    outline: none;
    background: white;
    cursor: inherit;
    display: block;
}
hr{
    margin-top: 15px;
    border: 1px solid #ddd;
    border-bottom: 0;
}
.pbSubheader {
    width:50%;
}
input[type='file'] {
  color: transparent;
}
.bPageBlock .detailList .labelCol {
    height: 19px;
}
.remove-firstoption > option:first-child{
    display:none;
}
.bs3 .panel-body {
    padding-top: 0px;
}
input[type="text"] {
    width: 120px;
}
.fromrebate,.fromrebate:hover{
    background:#ddd;
}
.borderred{
    border:1px solid red;
}
.bs3 .glyphicon-refresh-animate {
    -animation: spin .7s infinite linear;
    -webkit-animation: spin2 .7s infinite linear;
}
.bs3 .glyphicon-refresh-animate-slow {
    -animation: spin .9s infinite linear;
    -webkit-animation: spin2 .9s infinite linear;
}
@-webkit-keyframes spin2 {
    from { -webkit-transform: rotate(0deg);}
    to { -webkit-transform: rotate(360deg);}
}

@keyframes spin {
    from { transform: scale(1) rotate(0deg);}
    to { transform: scale(1) rotate(360deg);}
}