/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

open class MessageSizeCalculator: CellSizeCalculator {
  
  public init(layout: MessagesCollectionViewFlowLayout? = nil) {
    super.init()
    
    self.layout = layout
  }
  
  public var incomingAvatarSize = CGSize(width: 30, height: 30)
  public var outgoingAvatarSize = CGSize(width: 30, height: 30)
  
  public var incomingAvatarPosition = AvatarPosition(vertical: .cellBottom)
  public var outgoingAvatarPosition = AvatarPosition(vertical: .cellBottom)
  
  public var incomingMessagePadding =  NSEdgeInsets(left: 4, right: 30)
  public var outgoingMessagePadding = NSEdgeInsets(left: 30, right: 4)
  
  public var incomingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: NSEdgeInsetsZero)
  public var outgoingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: NSEdgeInsetsZero)
  
  public var incomingMessageTopLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: NSEdgeInsets(left: 42))
  public var outgoingMessageTopLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: NSEdgeInsets(right: 42))
  
  public var incomingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: NSEdgeInsets(left: 42))
  public var outgoingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: NSEdgeInsets(right: 42))
  
  public var incomingAccessoryViewSize = CGSize.zero
  public var outgoingAccessoryViewSize = CGSize.zero
  
  public var incomingAccessoryViewPadding = HorizontalEdgeInsets.zero
  public var outgoingAccessoryViewPadding = HorizontalEdgeInsets.zero
  
  open override func configure(attributes: NSCollectionViewLayoutAttributes) {
    guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
    
    let dataSource = messagesLayout.messagesDataSource
    guard let indexPath = attributes.indexPath else {
      return
    }
    
    let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
    
    attributes.avatarSize = avatarSize(for: message)
    attributes.avatarPosition = avatarPosition(for: message)
    
    attributes.messageContainerPadding = messageContainerPadding(for: message)
    attributes.messageContainerSize = messageContainerSize(for: message)
    attributes.cellTopLabelSize = cellTopLabelSize(for: message, at: indexPath)
    attributes.messageTopLabelSize = messageTopLabelSize(for: message, at: indexPath)
    attributes.messageTopLabelAlignment = messageTopLabelAlignment(for: message)
    
    attributes.messageBottomLabelAlignment = messageBottomLabelAlignment(for: message)
    attributes.messageBottomLabelSize = messageBottomLabelSize(for: message, at: indexPath)
    
    attributes.accessoryViewSize = accessoryViewSize(for: message)
    attributes.accessoryViewPadding = accessoryViewPadding(for: message)
  }
  
  open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
    let dataSource = messagesLayout.messagesDataSource
    let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
    let itemHeight = cellContentHeight(for: message, at: indexPath)
    return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
  }
  
  open func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
    
    let messageContainerHeight = messageContainerSize(for: message).height
    let messageBottomLabelHeight = messageBottomLabelSize(for: message, at: indexPath).height
    let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
    let messageTopLabelHeight = messageTopLabelSize(for: message, at: indexPath).height
    let messageVerticalPadding = messageContainerPadding(for: message).vertical
    let avatarHeight = avatarSize(for: message).height
    let avatarVerticalPosition = avatarPosition(for: message).vertical
    let accessoryViewHeight = accessoryViewSize(for: message).height
    
    switch avatarVerticalPosition {
    case .messageCenter:
      let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
        + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight
      let cellHeight = max(avatarHeight, totalLabelHeight)
      return max(cellHeight, accessoryViewHeight)
    case .messageBottom:
      var cellHeight: CGFloat = 0
      cellHeight += messageBottomLabelHeight
      let labelsHeight = messageContainerHeight + messageVerticalPadding + cellTopLabelHeight + messageTopLabelHeight
      cellHeight += max(labelsHeight, avatarHeight)
      return max(cellHeight, accessoryViewHeight)
    case .messageTop:
      var cellHeight: CGFloat = 0
      cellHeight += cellTopLabelHeight
      cellHeight += messageTopLabelHeight
      let labelsHeight = messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight
      cellHeight += max(labelsHeight, avatarHeight)
      return max(cellHeight, accessoryViewHeight)
    case .messageLabelTop:
      var cellHeight: CGFloat = 0
      cellHeight += cellTopLabelHeight
      let messageLabelsHeight = messageContainerHeight + messageBottomLabelHeight + messageVerticalPadding + messageTopLabelHeight
      cellHeight += max(messageLabelsHeight, avatarHeight)
      return max(cellHeight, accessoryViewHeight)
    case .cellTop, .cellBottom:
      let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
        + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight
      let cellHeight = max(avatarHeight, totalLabelHeight)
      return max(cellHeight, accessoryViewHeight)
    }
  }
  
  // MARK: - Avatar
  
  open func avatarPosition(for message: MessageType) -> AvatarPosition {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    var position = isFromCurrentSender ? outgoingAvatarPosition : incomingAvatarPosition
    
    switch position.horizontal {
    case .cellTrailing, .cellLeading:
      break
    case .natural:
      position.horizontal = isFromCurrentSender ? .cellTrailing : .cellLeading
    }
    return position
  }
  
  open func avatarSize(for message: MessageType) -> CGSize {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingAvatarSize : incomingAvatarSize
  }
  
  // MARK: - Top cell Label
  
  open func cellTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
    let layoutDelegate = messagesLayout.messagesLayoutDelegate
    let collectionView = messagesLayout.messagesCollectionView
    let height = layoutDelegate.cellTopLabelHeight(for: message, at: indexPath, in: collectionView)
    return CGSize(width: messagesLayout.itemWidth, height: height)
  }
  
  open func cellTopLabelAlignment(for message: MessageType) -> LabelAlignment {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingCellTopLabelAlignment : incomingCellTopLabelAlignment
  }
  
  // MARK: - Top message Label
  
  open func messageTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
    let layoutDelegate = messagesLayout.messagesLayoutDelegate
    let collectionView = messagesLayout.messagesCollectionView
    let height = layoutDelegate.messageTopLabelHeight(for: message, at: indexPath, in: collectionView)
    return CGSize(width: messagesLayout.itemWidth, height: height)
  }
  
  open func messageTopLabelAlignment(for message: MessageType) -> LabelAlignment {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingMessageTopLabelAlignment : incomingMessageTopLabelAlignment
  }
  
  // MARK: - Bottom Label
  
  open func messageBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
    let layoutDelegate = messagesLayout.messagesLayoutDelegate
    let collectionView = messagesLayout.messagesCollectionView
    let height = layoutDelegate.messageBottomLabelHeight(for: message, at: indexPath, in: collectionView)
    return CGSize(width: messagesLayout.itemWidth, height: height)
  }
  
  open func messageBottomLabelAlignment(for message: MessageType) -> LabelAlignment {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingMessageBottomLabelAlignment : incomingMessageBottomLabelAlignment
  }
  
  // MARK: - Accessory View
  
  public func accessoryViewSize(for message: MessageType) -> CGSize {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingAccessoryViewSize : incomingAccessoryViewSize
  }
  
  public func accessoryViewPadding(for message: MessageType) -> HorizontalEdgeInsets {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingAccessoryViewPadding : incomingAccessoryViewPadding
  }
  
  // MARK: - MessageContainer
  
  open func messageContainerPadding(for message: MessageType) -> NSEdgeInsets {
    let dataSource = messagesLayout.messagesDataSource
    let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
    return isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
  }
  
  open func messageContainerSize(for message: MessageType) -> CGSize {
    // Returns .zero by default
    return .zero
  }
  
  open func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
    let avatarWidth = avatarSize(for: message).width
    let messagePadding = messageContainerPadding(for: message)
    let accessoryWidth = accessoryViewSize(for: message).width
    let accessoryPadding = accessoryViewPadding(for: message)
    return messagesLayout.itemWidth - avatarWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal
  }
  
  // MARK: - Helpers
  
  public var messagesLayout: MessagesCollectionViewFlowLayout {
    guard let layout = layout as? MessagesCollectionViewFlowLayout else {
      fatalError("Layout object is missing or is not a MessagesCollectionViewFlowLayout")
    }
    return layout
  }
  
  internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
    let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
    let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral
    
    return rect.size
  }
}
