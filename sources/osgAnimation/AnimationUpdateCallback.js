'use strict';
var notify = require('osg/notify');
var utils = require('osg/utils');
var Object = require('osg/Object');
var MatrixTransform = require('osg/MatrixTransform');

/**
 *  AnimationUpdateCallback
 *  @class AnimationUpdateCallback
 */
var AnimationUpdateCallback = function() {
    Object.call(this);
};

// check if the path is animated, it could be elsewhere though
AnimationUpdateCallback.checkPathIsAnimated = function(path) {
    for (var i = 0, nbNodes = path.length; i < nbNodes; ++i) {
        var node = path[i];

        if (node instanceof MatrixTransform) {
            var ups = node.getUpdateCallbackList();
            for (var j = 0, nbUp = ups.length; j < nbUp; ++j) {
                if (ups[j] instanceof AnimationUpdateCallback) return true;
            }
        }
    }

    return false;
};

/** @lends AnimationUpdateCallback.prototype */
utils.createPrototypeObject(
    AnimationUpdateCallback,
    utils.objectInherit(Object.prototype, {
        linkChannel: function() {},
        linkAnimation: function(anim) {
            var name = this.getName();
            if (name.length === 0) {
                notify.log('no name on an update callback, discard');
                return 0;
            }
            var nbLinks = 0;
            var channels = anim.getChannels();
            for (var i = 0, l = channels.length; i < l; i++) {
                var channel = channels[i];
                if (channel.getTargetName() === name) {
                    this.linkChannel(channel);
                    nbLinks++;
                }
            }
            return nbLinks;
        }
    }),
    'osgAnimation',
    'AnimationUpdateCallback'
);

module.exports = AnimationUpdateCallback;
