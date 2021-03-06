/*
 * This file is part of the PanoramaGL library.
 *
 *  Author: Javier Baez <javbaezga@gmail.com>
 *
 *  $Id$
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; version 3 of
 * the License
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

#import "PLCamera.h"
#import "PLSceneElement.h"

@interface PLScene : NSObject 
{
    PLCamera * currentCamera;
    
	NSMutableArray * cameras;
	
	NSUInteger cameraIndex;
	
	NSMutableArray * elements;
}

@property (nonatomic, readonly) NSMutableArray * cameras;
@property (nonatomic, readonly) PLCamera * currentCamera;
@property (nonatomic) NSUInteger cameraIndex;

@property (nonatomic, readonly) NSMutableArray * elements;

- (id)initWithCamera:(PLCamera *)camera;
- (id)initWithElement:(PLSceneElement *)element;
- (id)initWithElement:(PLSceneElement *)element camera:(PLCamera *)camera;

+ (id)scene;
+ (id)sceneWithCamera:(PLCamera *)camera;
+ (id)sceneWithElement:(PLSceneElement *)element;
+ (id)sceneWithElement:(PLSceneElement *)element camera:(PLCamera *)camera;

- (void)addCamera:(PLCamera *)camera;
- (void)removeCameraAtIndex:(NSUInteger)index;

- (void)addElement:(PLSceneElement *)element;
- (void)removeElementAtIndex:(NSUInteger)index;
- (void)removeAllElements;

@end
