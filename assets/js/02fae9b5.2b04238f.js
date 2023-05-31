"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[331],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>m});var r=n(67294);function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){a(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,r,a=function(e,t){if(null==e)return{};var n,r,a={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(a[n]=e[n]);return a}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var u=r.createContext({}),c=function(e){var t=r.useContext(u),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=c(e.components);return r.createElement(u.Provider,{value:t},e.children)},d="mdxType",s={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},f=r.forwardRef((function(e,t){var n=e.components,a=e.mdxType,i=e.originalType,u=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),d=c(n),f=a,m=d["".concat(u,".").concat(f)]||d[f]||s[f]||i;return n?r.createElement(m,o(o({ref:t},p),{},{components:n})):r.createElement(m,o({ref:t},p))}));function m(e,t){var n=arguments,a=t&&t.mdxType;if("string"==typeof e||a){var i=n.length,o=new Array(i);o[0]=f;var l={};for(var u in t)hasOwnProperty.call(t,u)&&(l[u]=t[u]);l.originalType=e,l[d]="string"==typeof e?e:a,o[1]=l;for(var c=2;c<i;c++)o[c]=n[c];return r.createElement.apply(null,o)}return r.createElement.apply(null,n)}f.displayName="MDXCreateElement"},24948:(e,t,n)=>{n.r(t),n.d(t,{contentTitle:()=>o,default:()=>d,frontMatter:()=>i,metadata:()=>l,toc:()=>u});var r=n(87462),a=(n(67294),n(3905));const i={},o="UnifiedData",l={type:"mdx",permalink:"/UnifiedData/",source:"@site/pages/index.md",title:"UnifiedData",description:"Very very simple module for managing trivial data that is shared from the server to the client.",frontMatter:{}},u=[{value:"Documentation",id:"documentation",level:2},{value:"Usage",id:"usage",level:2},{value:"Building",id:"building",level:3}],c={toc:u},p="wrapper";function d(e){let{components:t,...n}=e;return(0,a.kt)(p,(0,r.Z)({},c,n,{components:t,mdxType:"MDXLayout"}),(0,a.kt)("h1",{id:"unifieddata"},"UnifiedData"),(0,a.kt)("p",null,"Very very simple module for managing trivial data that is shared from the server to the client.\nThe use-case is for when the server has a large but mostly non-volatile amount of data that needs to be synced\nto all clients and inconvenient to facilitate outside of code."),(0,a.kt)("h2",{id:"documentation"},"Documentation"),(0,a.kt)("p",null,"Documentation can be found at ",(0,a.kt)("a",{parentName:"p",href:"https://phantomshift.github.io/UnifiedData/"},"https://phantomshift.github.io/UnifiedData/")),(0,a.kt)("h2",{id:"usage"},"Usage"),(0,a.kt)("p",null,"Intended to be placed in ReplicatedStorage, but should work as long as the same ModuleScript is visible from both the Server and Client."),(0,a.kt)("p",null,"You can either build the model yourself or grab the ",(0,a.kt)("inlineCode",{parentName:"p"},"rbxm")," from this repo (which should be the same as building it yourself if I haven't been lazy).\nBuild artifacts can be found in the ",(0,a.kt)("a",{parentName:"p",href:"https://github.com/PhantomShift/UnifiedData/actions"},"GitHub Actions tab"),"."),(0,a.kt)("p",null,"Alternatively, the code can be copied manually. If doing so, ensure that the following hierarchy and names is recreated:"),(0,a.kt)("ul",null,(0,a.kt)("li",{parentName:"ul"},"UnifiedData ",(0,a.kt)("inlineCode",{parentName:"li"},"ModuleScript"),(0,a.kt)("ul",{parentName:"li"},(0,a.kt)("li",{parentName:"ul"},"Client ",(0,a.kt)("inlineCode",{parentName:"li"},"ModuleScript")),(0,a.kt)("li",{parentName:"ul"},"DataFolder ",(0,a.kt)("inlineCode",{parentName:"li"},"Folder")),(0,a.kt)("li",{parentName:"ul"},"Server ",(0,a.kt)("inlineCode",{parentName:"li"},"ModuleScript")),(0,a.kt)("li",{parentName:"ul"},"Shared ",(0,a.kt)("inlineCode",{parentName:"li"},"ModuleScript"))))),(0,a.kt)("h3",{id:"building"},"Building"),(0,a.kt)("p",null,"UnifiedData depends on ",(0,a.kt)("a",{parentName:"p",href:"https://github.com/rojo-rbx/rojo"},"rojo")," for building from source."),(0,a.kt)("pre",null,(0,a.kt)("code",{parentName:"pre",className:"language-bash"},'rojo build -o "UnifiedData.rbxmx"\n')))}d.isMDXComponent=!0}}]);